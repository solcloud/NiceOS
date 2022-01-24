echo "Enter root password"
passwd

locale-gen
mkdir -p /var/cache/
ldconfig --ignore-aux-cache # create /etc/ld.so.cache and /var/cache/ldconfig/aux-cache

groupadd -g 975 docker
groupadd -g 7001 code
useradd -s /bin/bash -g 7001 -G 7001,975 -m -u 7001 code
printf "dan\ndan" | passwd code

chown -R code:code /home/code
ln -s /code /home/code/src
ln -s /code/solcloud/dev-stack/bin/dev-stack.sh /usr/bin/dev
ln -s /tmp/ /var/tmp

chmod 0600 /etc/ssh/ssh_host_ed25519_key
chmod o+r /etc/resolv.conf
chmod 0700 /home/code/
chmod -R 0700 /home/code/.ssh/

mkdir -p /code /data
chmod o+rwX /code
chmod o+rwX /data

echo 'tag        /code    virtiofs    rw,_netdev,noatime,nodiratime  0   0' >> /etc/fstab
echo '/dev/sdb   /data    ext4        rw,noatime,nodiratime          0   0' >> /etc/fstab
mount -a

mkdir -p /data/images
