LVM_UUID=$1 
EFI_UUID=$2
DEV_NAME=$3

sudo cryptsetup luksOpen /dev/disk/by-uuid/${LVM_UUID} ${DEV_NAME}
sudo vgchange -ay
sudo mount /dev/${DEV_NAME}/nix-root /mnt
sudo mount /dev/${DEV_NAME}/home /mnt/home
sudo mount /dev/disk/by-uuid/${EFI_UUID} /mnt/boot
