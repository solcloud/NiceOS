echo "Starting installer"

mkfs.ext4 -F /dev/sda
mount /dev/sda /mnt/

debootstrap --variant=minbase --merged-usr --arch=amd64 --include="$(cat /tmp/packages.deb | xargs | sed 's/ /,/g')" chimaera /mnt

chroot /mnt /bin/bash -c '

echo "Cleaning installation"
'

sync
poweroff
