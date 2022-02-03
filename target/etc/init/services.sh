#!/bin/sh

set -e

if [ -x /bin/udevd ]; then
    /etc/init/udev_refresh.sh
else
    busybox mdev -s
fi

sleep 2 && /etc/init/network.sh > /dev/null 2>& 1 &

[ -x /etc/start_services.sh ] && /etc/start_services.sh &

wait
