# tiny disk migration plan

This documents the planned migration of `tiny` from the current disk to `/dev/sdb`, using:

- `pvmove` for `/home`
- a fresh `nixos-install` for `/`
- later cleanup and rename of the VG to `tiny`

## Current assumptions

Current storage layout:

- old LUKS mapping: `/dev/mapper/sanjota`
- new LUKS mapping: `/dev/mapper/tiny`
- current VG: `sanjota`
- current root LV: `/dev/sanjota/nix-root`
- current home LV: `/dev/sanjota/home`

Target end state:

- boot from `/dev/sdb1`
- LUKS on `/dev/sdb2`
- final VG name: `tiny`
- final root LV: `/dev/tiny/nix-root`
- final home LV: `/dev/tiny/home`

---

## 1. Reset `/dev/sdb`

If `/dev/sdb` still contains previous experiments, reset it first.

Replace `<SDB_LUKS_NAME_NOW>` and `<SDB_VG_NOW>` with the currently active names if needed.

```bash
sudo umount -R /mnt
sudo vgchange -an <SDB_VG_NOW>
sudo cryptsetup close <SDB_LUKS_NAME_NOW>
lsblk -f /dev/sdb
sudo wipefs -a /dev/sdb
sudo sgdisk --zap-all /dev/sdb
# optional on SSD
sudo blkdiscard /dev/sdb || true
```

---

## 2. Partition and initialize `/dev/sdb`

```bash
sudo parted -s /dev/sdb -- \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart luks 513MiB 100%

sudo mkfs.vfat -F 32 -n EFI-TINY /dev/sdb1
sudo cryptsetup luksFormat /dev/sdb2
sudo cryptsetup open /dev/sdb2 tiny
sudo pvcreate /dev/mapper/tiny
sudo vgextend sanjota /dev/mapper/tiny
```

Verify:

```bash
sudo pvs -o pv_name,vg_name,pv_size,pv_free
sudo vgs -o vg_name,vg_size,vg_free
```

### What `vgextend sanjota /dev/mapper/tiny` means

This adds the new PV to the existing VG.

After this, VG `sanjota` spans both encrypted devices:

- old PV: `/dev/mapper/sanjota`
- new PV: `/dev/mapper/tiny`

So `sanjota` becomes one storage pool over both disks.

---

## 3. Move only `/home` with `pvmove`

```bash
sudo modprobe dm_mirror dm_log dm_region_hash dm_raid
sudo pvmove -i 10 -n sanjota/home /dev/mapper/sanjota /dev/mapper/tiny
```

Verify afterwards:

```bash
sudo lvs -o lv_name,vg_name,lv_size,devices sanjota/home sanjota/nix-root
sudo pvs -o pv_name,vg_name,pv_used,pv_free
```

Expected:

- `home` only on `/dev/mapper/tiny`
- `nix-root` still on `/dev/mapper/sanjota`

Note: `/home` still appears as `/dev/sanjota/home`. Only its backing extents moved.

---

## 4. Create the new root LV on the new disk

Choose the desired root size. Example: `160G`.

```bash
sudo lvcreate -L 160G -n nix-root-new sanjota /dev/mapper/tiny
sudo mkfs.ext4 -L tiny-root /dev/sanjota/nix-root-new
```

Optional check:

```bash
sudo lvs -o lv_name,vg_name,lv_size,devices sanjota/nix-root-new
```

---

## 5. Get new UUIDs

```bash
NEW_BOOT_UUID=$(blkid -s UUID -o value /dev/sdb1)
NEW_LUKS_UUID=$(blkid -s UUID -o value /dev/sdb2)
echo "$NEW_BOOT_UUID"
echo "$NEW_LUKS_UUID"
```

Keep these values for the temporary and final config edits.

---

## 6. Mount the target for installation

```bash
sudo umount -R /mnt 2>/dev/null || true
sudo mount /dev/sanjota/nix-root-new /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sdb1 /mnt/boot
```

Optional:

```bash
sudo mkdir -p /mnt/home
sudo mount --bind /home /mnt/home
```

---

## 7. Temporary `tiny.nix` changes for first boot on the new root

Edit `nixos-systems/tiny.nix`.

### 7.1 Temporary dual-LUKS initrd config

Replace the current single-device LUKS config with:

```nix
boot = {
  initrd.luks = {
    fido2Support = false;
    devices = {
      sanjota = {
        preLVM = true;
        device = "/dev/disk/by-uuid/462786d0-1145-4540-9212-d14c8db7b341";
      };
      tiny = {
        preLVM = true;
        device = "/dev/disk/by-uuid/<NEW_LUKS_UUID>";
      };
    };
  };
```

This is required because VG `sanjota` still spans both disks for the first boot.

### 7.2 Temporary filesystem config

Replace the current filesystem section with:

```nix
fileSystems = {
  "/boot" = {
    device = "/dev/disk/by-uuid/<NEW_BOOT_UUID>";
    fsType = "vfat";
    neededForBoot = true;
  };
  "/" = {
    device = "/dev/sanjota/nix-root-new";
    fsType = "ext4";
    neededForBoot = true;
  };
  "/home" = {
    device = "/dev/sanjota/home";
    fsType = "ext4";
    neededForBoot = true;
  };
};
```

---

## 8. Install the new system

From `nixos-systems/`:

```bash
sudo nixos-install --root /mnt --flake .#tiny
```

---

## 9. Reboot into the new system

```bash
sudo reboot
```

Boot from the new disk.

There is no need for an extra intermediate “hybrid reboot” before `nixos-install`.

---

## 10. Verify after first boot

```bash
mount | grep ' on / '
mount | grep ' on /home '
sudo lvs -o lv_name,vg_name,lv_size,devices
sudo pvs -o pv_name,vg_name,pv_used,pv_free
```

Expected:

- `/` on `nix-root-new`
- `/home` on `home`
- VG still named `sanjota`
- VG still spans both disks

---

## 11. Remove the old root and old PV from the VG

```bash
sudo lvremove /dev/sanjota/nix-root
sudo vgreduce sanjota /dev/mapper/sanjota
```

Verify:

```bash
sudo pvs -o pv_name,vg_name,pv_used,pv_free
```

Expected: only `/dev/mapper/tiny` remains in VG `sanjota`.

---

## 12. Grow `/home` to use the remaining free space

This is the best time to do it:

- after booting successfully from the new root
- after removing the old root LV
- after `vgreduce` removed the old PV

Reason: if done earlier, `lvextend -l +100%FREE` could allocate space from the old PV.

### Option A: grow before VG rename

```bash
sudo lvextend -r -l +100%FREE /dev/sanjota/home
```

### Option B: leave some free space instead

Example:

```bash
sudo lvextend -r -L +200G /dev/sanjota/home
```

`-r` resizes the filesystem too.

---

## 13. Rename the VG to `tiny`

```bash
sudo vgrename sanjota tiny
```

Rename the new root LV too:

```bash
sudo lvrename tiny nix-root-new nix-root
```

Verify:

```bash
sudo lvs -o lv_name,vg_name,lv_size,devices
```

Expected paths:

- `/dev/tiny/nix-root`
- `/dev/tiny/home`

If `/home` was not yet extended in step 12, do it now instead:

```bash
sudo lvextend -r -l +100%FREE /dev/tiny/home
```

---

## 14. Final `tiny.nix` cleanup

Edit `nixos-systems/tiny.nix` again.

### 14.1 Final initrd LUKS config

Replace the temporary dual-device setup with:

```nix
boot = {
  initrd.luks = {
    fido2Support = false;
    devices = {
      tiny = {
        preLVM = true;
        device = "/dev/disk/by-uuid/<NEW_LUKS_UUID>";
      };
    };
  };
```

### 14.2 Final filesystem config

Replace the temporary filesystem config with:

```nix
fileSystems = {
  "/boot" = {
    device = "/dev/disk/by-uuid/<NEW_BOOT_UUID>";
    fsType = "vfat";
    neededForBoot = true;
  };
  "/" = {
    device = "/dev/tiny/nix-root";
    fsType = "ext4";
    neededForBoot = true;
  };
  "/home" = {
    device = "/dev/tiny/home";
    fsType = "ext4";
    neededForBoot = true;
  };
};
```

---

## 15. Build boot config and reboot one last time

```bash
sudo nixos-rebuild boot --flake .#tiny
sudo reboot
```

---

## 16. Final verification

```bash
mount | grep ' on / '
mount | grep ' on /home '
sudo lvs -o lv_name,vg_name,lv_size,devices
sudo pvs -o pv_name,vg_name,pv_used,pv_free
lsblk -f
```

Expected final state:

- boot from `/dev/sdb1`
- LUKS on `/dev/sdb2`
- VG name `tiny`
- `/` on `/dev/tiny/nix-root`
- `/home` on `/dev/tiny/home`

---

## Notes

- `pvmove` requires kernel device-mapper targets such as `dm_mirror`, `dm_log`, `dm_region_hash`, and sometimes `dm_raid`.
- The partition alignment warning from `parted` was not considered a blocker; the partition starts are 1 MiB aligned.
- Influx data was already moved to `/home/influxdb2` via a bind mount to `/var/lib/influxdb2`, so reinstalling `/` is acceptable.
