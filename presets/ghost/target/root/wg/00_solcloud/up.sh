#!/bin/sh

source ./env

ip link add dev $INTERFACE type wireguard
ip addr add 192.168.231.11/24 dev $INTERFACE # config load buggy for ip
wg setconf $INTERFACE ./local.config
ip link set $INTERFACE up

OIFS=$IFS
IFS=','
for ip in IP_POOLS; do
    ip rou add $ip dev $INTERFACE
done
IFS=$OIFS


iptables -I OUTPUT -o eth0 -p udp --destination $ENDPOINT_IP --dport $ENDPOINT_PORT -j ACCEPT
iptables -I OUTPUT -o eth0 --destination $IP_POOLS -m owner --uid-owner daniel -j ACCEPT
