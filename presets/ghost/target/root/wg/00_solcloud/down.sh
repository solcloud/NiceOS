#!/bin/sh

source ./env

ip link set $INTERFACE down

iptables -D OUTPUT -o eth0 -p udp --destination $ENDPOINT_IP --dport $ENDPOINT_PORT -j ACCEPT
iptables -D OUTPUT -o eth0 --destination $IP_POOLS -m owner --uid-owner daniel -j ACCEPT

ip link delete $INTERFACE
