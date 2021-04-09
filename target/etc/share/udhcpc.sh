#!/bin/sh

PATH=/bin
RESOLV_CONF="/etc/resolv.conf"

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

case "$1" in
        deconfig)
                ip addr flush dev "$interface"
                ip link set dev "$interface" up
                ;;

        renew|bound)
                ip addr add dev "$interface" local "${ip}/${mask}"

                if [ -n "$router" ] ; then
                        echo "Deleting routers"
                        while busybox route del default 2> /dev/null ; do
                                :
                        done

                        for i in $router ; do
                                busybox route add default gw "$i" dev "$interface"
                        done
                fi

                #echo -n > $RESOLV_CONF
                for i in $dns ; do
                        echo "Got dns $i"
                        #echo "nameserver $i" >> $RESOLV_CONF
                done
                ;;
esac

exit 0
