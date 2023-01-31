DEV_NAME=$1
mount | rg --color=auto mnt | cut -f 3 -d' ' | sort -r | xargs -n 1 sudo umount
sudo vgchange -an $DEV_NAME
sudo cryptsetup luksClose yuking
