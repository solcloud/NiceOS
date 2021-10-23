echo "Starting installer"

mkfs.ext4 -F /dev/sda
mount /dev/sda /mnt/

debootstrap --merged-usr --arch=amd64 --include="$(cat /tmp/packages | xargs | sed 's/ /,/g')" chimaera /mnt

chroot /mnt /bin/bash -c '

echo "Cleaning installation"
'

sync
poweroff
