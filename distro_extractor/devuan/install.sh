arch='amd64'
suite='chimaera'

mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/
echo "Starting installer"

debootstrap --variant=minbase --merged-usr --arch="$arch" "$suite" /mnt
cat /tmp/packages.deb.txt | xargs > /mnt/tmp/packages
chroot /mnt /bin/sh -c '
apt-get update
apt-get --fix-broken install --assume-yes
apt-get --fix-missing install --assume-yes
apt-get install --no-install-recommends --assume-yes $(cat /tmp/packages)

echo "Cleaning installation"
# Get rid off /sbin
mv /usr/sbin/* /usr/bin/
rm /usr/sbin/*
rmdir /usr/sbin/
ln -s /usr/bin /usr/sbin

rm -f /usr/bin/iptables
ln -s /usr/bin/iptables-legacy /usr/bin/iptables

'

sync
umount /mnt/
poweroff
