#!/bin/sh

INTERFACE="${1:-eth0}"

# -t N      Send up to N discover packets
# -T SEC    Pause between packets
# -A SEC    Wait if lease is not obtained
# -n        Exit if lease is not obtained
# -q        Exit after obtaining lease
busybox udhcpc -s /etc/share/udhcpc.sh \
    -t 5 \
    -T 2 \
    -A 1 \
    -n \
    -q \
    -i $INTERFACE

mount -a -O _netdev
