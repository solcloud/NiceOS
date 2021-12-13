#!/bin/sh

LOCAL_SSH_PORT=22
LOCAL_HTTP_PORT=8080
SSH_PORTS=22,2201,2202
ALLOWED_USERS="firefox" # DNS,HTTP(S),WEBSOCKET
ALLOWED_SSH_USERS="dan daniel"

# Drop invalid packets on INPUT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
# Allow INPUT established, related sessions
iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ICMP
iptables -A INPUT -p icmp -j DROP

# Disable SMTP outgoing mail
iptables -A OUTPUT -p tcp -m multiport --dports 25,465 -j REJECT

# Allow internet access for specific users
/etc/internet.sh allow "$ALLOWED_USERS"

iptables -A OUTPUT -p udp --dport 53 -j REJECT # BLOCK outgoing udp DNS
iptables -A INPUT -p udp --sport 53 -j DROP # BLOCK incoming udp DNS
iptables -A OUTPUT -p tcp --dport 53 -j REJECT # BLOCK outgoing tcp DNS
iptables -A INPUT -p tcp --sport 53 -j DROP # BLOCK incoming tcp DNS

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow ssh
iptables -A INPUT -p tcp --dport $LOCAL_SSH_PORT -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
for user in $ALLOWED_SSH_USERS; do
    iptables -A OUTPUT -p tcp -m multiport --dports $SSH_PORTS -m owner --uid-owner $user -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
done
iptables -A OUTPUT -p tcp --sport $LOCAL_SSH_PORT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow local http server
iptables -A INPUT -p tcp --dport $LOCAL_HTTP_PORT -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport $LOCAL_HTTP_PORT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow dns user perform https query (DOH)
iptables -A OUTPUT -p tcp --dport 443 --destination 8.8.8.8,1.1.1.1 -m owner --uid-owner dns -j ACCEPT




# Block everything else :)
# Reject feedback because of default policy cannot reject, only drop or accept
iptables -A INPUT -j REJECT --reject-with icmp-admin-prohibited
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited
# Default chain policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
# IPv6
#ip6tables -P INPUT DROP
#ip6tables -P FORWARD DROP
#ip6tables -P OUTPUT DROP
