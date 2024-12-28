# Setting up a new system

Setup notes for adding a new system. Incomplete and wrong, as per usual.

## Setup: from host system

For clean disk:
```fish
sudo fdisk /dev/sda
```
- new partition table
- partition 1: 1G, type = 1 (EFI System),
- partition 2: type = 83

```fish
set NAME <your system name>
set EFI /dev/nvme0n1p1
set LVM /dev/nvme0n1p2
# set EFI /dev/sda1
# set LVM /dev/sda2

# initial setup doesn't have UUIDs yet, they are part of vfat / luks setup itself
sudo mkfs.vfat $EFI
sudo cryptsetup luksFormat $LVM
```

```fish
set EFI_UUID <uuid of $EFI>
set LVM_UUID <uuid of $LVM>
sudo cryptsetup luksOpen /dev/disk/by-uuid/$LVM_UUID {$NAME}
sudo vgcreate {$NAME} /dev/mapper/$NAME

# adapt the sizes as you see fit
sudo lvcreate -L 128G -n nix-root  {$NAME}
sudo lvcreate -L 32G -n swap {$NAME}

# optional: will I ever install another OS, again?
sudo lvcreate -L 64G -n alt {$NAME}
sudo lvcreate -l 100%FREE  -n home {$NAME}

sudo mkfs.ext4 -L nix-root /dev/{$NAME}/nix-root
sudo mkfs.ext4 -L home /dev/{$NAME}/home

sudo mkswap /dev/{$NAME}/swap
```

```fish
# choose your base wisely!
z dot/nixo
cp x12.nix $NAME.nix
git add $NAME.nix
nvim flake.nix $NAME.nix
```
create new system file and edit
- `$NAME` into hostname
- `$EFI_UUID` -> `/boot` 
- `$LVM_UUID` -> `devices.$NAME.device=/dev/disk/by-uuid/$LVM`
- `fileSystems` -> ` ... /dev/$NAME`

```fish
sudo mkdir /mnt
,nix-root-mount.sh $LVM_UUID $EFI_UUID $NAME

sudo mkdir -p /mnt/home/pi
sudo mkdir -p /mnt/home/data/tmp/screenshots
sudo chmod 1777 /mnt/home/data
sudo chown pi:users /mnt/home/pi
mkdir -p /mnt/home/pi/projects/
mkdir -p /mnt/home/pi/.password-store

rsync -aH --info=progress2 --stats (git root) /mnt/home/pi/src/github/dispanser/ --delete

# note the `/mnt`: we want to keep iterating on the copied version in case we mess up
sudo nixos-install --flake /mnt/home/pi/src/github/dispanser/dot-files/nixos-systems/\#{$NAME}
```

following steps can be done while system is building, which takes a while:

```fish
# this may not be the best way to sync things... far too much data
# rsync -aH --info=progress2 --stats ~/projects/ /mnt/home/pi/projects/

# top priority is to get access to tiny for unison, and github for config repos
mkdir /mnt/home/pi/.ssh/; 
cp \
	/home/pi/.ssh/yubikey_c.pub \
	/home/pi/.ssh/id_feitian_solo_ecdsa_sk \
	/home/pi/.ssh/id_feitian_chain_ecdsa_sk \
	/home/pi/.ssh/id_ecdsa /mnt/home/pi/.ssh/
# also copy `.pub` over, `ssh-copy-id` didn't work for whatever reason
ssh-keygen -t ed25519 -C "tiny@{$NAME}" -f /mnt/home/pi/.ssh/unison-tiny

# finally, unmount
,umount-mnt.sh {$NAME}
```

We're done. Boot, and find out all the things we forgot. Add them here, because we want to do better next time

## post-boot

```fish
# pull backup, prefer remote data
unison tinyx -ui text -repeat watch -prefer ssh://tiny//home/data/sync/home/pi/

```
