echo "Starting installer"

mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

pacstrap /mnt $(cat /tmp/packages.arch.txt | xargs)

sync
umount /mnt/
poweroff
