# Storage cheat-sheet

## Investigate current state
Quickly see disks, mounts, filesystems, LUKS/LVM structure, and usage before touching anything.

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS,MODEL
findmnt
blkid
sudo pvs -o pv_name,pv_size,pv_free,vg_name
sudo vgs -o vg_name,vg_size,vg_free
sudo lvs -o lv_name,vg_name,lv_size,devices
df -hT
```

## Check drive health
For SATA/NVMe health, read SMART and optionally run a short self-test; useful before reusing an old disk.

```bash
nix shell nixpkgs#smartmontools -c bash -lc 'sudo $(command -v smartctl) -x /dev/sdX'
nix shell nixpkgs#smartmontools -c bash -lc 'sudo $(command -v smartctl) -t short /dev/sdX'
```

## Partition + LUKS + LVM
Typical fresh layout: small EFI, one large LUKS container, then PV/VG/LVs inside.

```bash
sudo wipefs -a /dev/sdX
sudo sgdisk --zap-all /dev/sdX
sudo parted -s /dev/sdX -- mklabel gpt mkpart ESP fat32 1MiB 513MiB set 1 esp on mkpart luks 513MiB 100%
sudo mkfs.vfat -F 32 -n EFI-NAME /dev/sdX1
sudo cryptsetup luksFormat /dev/sdX2
sudo cryptsetup open /dev/sdX2 vg-crypt
sudo pvcreate /dev/mapper/vg-crypt
sudo vgcreate vgname /dev/mapper/vg-crypt
sudo lvcreate -L 140G -n nix-root vgname
sudo lvcreate -l 100%FREE -n home vgname
sudo mkfs.ext4 -L nix-root /dev/vgname/nix-root
sudo mkfs.ext4 -L home /dev/vgname/home
```

## Copy live data safely
For moving data while staying online, do one rsync pass live, stop writers, then a final `--delete` pass.

```bash
sudo mount /dev/vgname/home /mnt
sudo rsync -aHAX --numeric-ids --info=progress2 /home/ /mnt/
# stop writers/services here
sudo rsync -aHAX --numeric-ids --delete --info=progress2 /home/ /mnt/
```

## Move an LV with `pvmove`
`pvmove` relocates LVM extents between PVs without changing LV names; the target only needs enough free extents for the moved data.

```bash
sudo modprobe dm_mirror dm_log dm_region_hash dm_raid
sudo vgextend vgname /dev/mapper/new-pv
sudo pvmove -i 10 -n vgname/home /dev/mapper/old-pv /dev/mapper/new-pv
sudo lvs -o lv_name,vg_name,lv_size,devices vgname/home
```

## Resize volumes
Grow online when possible; shrinking ext4 is offline and should be done carefully.

```bash
sudo lvextend -r -l +100%FREE /dev/vgname/home
sudo lvextend -r -L +200G /dev/vgname/home
sudo e2fsck -f /dev/vgname/home
sudo resize2fs /dev/vgname/home 300G
sudo lvreduce -L 300G /dev/vgname/home
```

## Rename VG/LV and labels
After migration cleanup, rename the VG/LV and normalize filesystem labels.

```bash
sudo vgrename oldvg newvg
sudo lvrename newvg oldlv newlv
sudo e2label /dev/newvg/newlv new-label
```

## Mount a separate data disk in NixOS
For required storage, unlock the extra LUKS device in initrd and mount it declaratively.

```nix
boot.initrd.luks.devices.sanjota = {
  preLVM = true;
  device = "/dev/disk/by-uuid/<luks-uuid>";
};

fileSystems."/home/data" = {
  device = "/dev/sanjota/data";
  fsType = "ext4";
  neededForBoot = true;
};
```

## Apply and verify
Build/switch the config, then confirm the right devices are mounted.

```bash
sudo nixos-rebuild switch --flake .#tiny
findmnt / /home /boot /home/data
lsblk -f
```
