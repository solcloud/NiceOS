echo "Starting installer"

mkfs.ext4 -F /dev/sda
mount /dev/sda /mnt/

debootstrap --variant=minbase --merged-usr --arch=amd64 --include="$(cat /tmp/packages.deb.txt | xargs | sed 's/ /,/g')" chimaera /mnt

chroot /mnt /bin/bash -c '

echo "Cleaning installation"
apt-get update
apt-get --fix-broken install -y
apt-get --fix-missing install -y

# get ridd off /sbin
mv /usr/sbin/* /usr/bin/
rm /usr/sbin/*
rmdir /usr/sbin/
ln -s /usr/bin /usr/sbin

pushd /usr/bin
    rm -f iptables
    ln -s iptables-legacy iptables


    # currently debian has buggy kmod for loading self built modules (sign, compression, something - dont know for sure till 5.16 stable), use busybox version for now
    rm kmod && ln -s busybox kmod
popd


'

sync
poweroff
