#!/bin/sh

if [ "x$1" = "xa" ]; then
    # Remove blocking rules
    iptables -D INPUT -i eth0 -j REJECT
    iptables -D OUTPUT -o eth0 -j REJECT
elif [ "x$1" = "xd" ]; then
    # Add blocking rules
    iptables -A INPUT -i eth0 -j REJECT
    iptables -A OUTPUT -o eth0 -j REJECT
else
    echo "Usage $0 [a]llow | [d]eny"
    exit 1
fi

exit 0
