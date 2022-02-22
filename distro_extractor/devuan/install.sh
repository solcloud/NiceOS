echo "Starting installer"

mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

arch='amd64'
debootstrap --variant=minbase --merged-usr --arch="$arch" --exclude="linux-image-$arch,linux-image-rt-$arch" --include="$(cat /tmp/packages.deb.txt | xargs | sed 's/ /,/g')" chimaera /mnt

chroot /mnt /bin/sh -c '

echo "Cleaning installation"
apt-get update
apt-get --fix-broken install -y
apt-get --fix-missing install -y

# get rid off /sbin
mv /usr/sbin/* /usr/bin/
rm /usr/sbin/*
rmdir /usr/sbin/
ln -s /usr/bin /usr/sbin

pushd /usr/bin
    rm -f iptables
    ln -s iptables-legacy iptables
popd


'

sync
poweroff
