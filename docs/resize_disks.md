# Don't cheap out on space in the root FS

Seriously - NixOS takes lots of space, in particular if you also run a bunch of devenvs that. Just make it >= 200G. More is better.

## Extending entire partition hosting LVM

## Preparation (from running system)

### Note the LUKS UUID for later
sudo cryptsetup luksUUID /dev/nvme0n1p2
### Should be: 65693a87-f256-4644-aaa1-262594df19a1

### Steps (from live USB environment)

### 1. Boot live USB, unlock LUKS

sudo cryptsetup open /dev/nvme0n1p2 konsole
# Enter passphrase

### 2. Check current state

sudo pvs
sudo vgs
lsblk

### 3. Grow partition p2 (DANGEROUS - triple-check!)

sudo parted /dev/nvme0n1
# Inside parted:
(parted) print
(parted) resizepart 2 100%
(parted) quit

### 4. Grow LUKS container

sudo cryptsetup resize konsole

### 5. Grow Physical Volume

sudo pvresize /dev/mapper/konsole

### 6. Extend nix-root

sudo lvextend -l +100%FREE /dev/konsole/nix-root
sudo resize2fs /dev/konsole/nix-root

### 7. Reboot

sudo reboot
