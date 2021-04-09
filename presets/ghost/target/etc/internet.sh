#!/bin/bash

set -e

PORTS="80,443"

if [ ! "$2" ]; then
    echo "Usage $0 allow|deny USER"
    exit 1
fi

users="$2"
if [ "$1" = "allow" ]; then
    for user in $users; do
        iptables -I OUTPUT -t nat -o lo -p udp --dport 53 -m owner --uid-owner $user -j REDIRECT --to-ports 5353
        iptables -I OUTPUT -p tcp -m owner --uid-owner $user -m multiport --dports $PORTS -j ACCEPT
    done
elif [ "$1" = "deny" ]; then
    for user in $users; do
        iptables -D OUTPUT -t nat -o lo -p udp --dport 53 -m owner --uid-owner $user -j REDIRECT --to-ports 5353
        iptables -D OUTPUT -p tcp -m owner --uid-owner $user -m multiport --dports $PORTS -j ACCEPT
    done
else
    echo "Accept only 'allow' or 'deny'"
    exit 1
fi
