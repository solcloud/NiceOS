#!/bin/sh

set -e

iptables -F -t nat
iptables -F -t raw
iptables -F -t mangle
iptables -F -t filter

/etc/iptables.sh

echo "Done"
