#!/bin/sh

set -e

if [[ $(ls /bin/udevd 2> /dev/null) ]]; then
    /etc/init/udev_refresh.sh
else
    busybox mdev -s
fi

sleep 3 && /etc/init/network.sh > /dev/null 2>& 1 &
busybox loadkmap < /etc/share/kmap/cz-qwertz.map

[ -x /etc/start_services.sh ] && /etc/start_services.sh &

wait