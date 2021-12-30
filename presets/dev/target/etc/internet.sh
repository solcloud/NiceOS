#!/bin/sh

if [ "x$1" = "xallow" ]; then
    # Remove blocking rules
    iptables -D INPUT -i eth0 -j REJECT
    iptables -D OUTPUT -o eth0 -j REJECT
elif [ "x$1" = "xdeny" ]; then
    # Add blocking rules
    iptables -A INPUT -i eth0 -j REJECT
    iptables -A OUTPUT -o eth0 -j REJECT
else
    echo "Usage $0 allow | deny"
    exit 1
fi

exit 0
