#!/bin/sh

# Firewall rules for router(hermes)

# Location of iptables
IPT="/sbin/iptables"

# Network Interfaces
LAN="eth0"    # Ethernet
WAN="eth1"    # Wireless

# Flush old rules and old custom tables
$IPT --flush 
$IPT -t nat --flush 
$IPT --delete-chain

# Set the default policies
$IPT -P INPUT DROP
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD DROP

# Allow Loopback interface 
$IPT -A INPUT -i lo -j ACCEPT 
$IPT -A OUTPUT -o lo -j ACCEPT 

# NATing
$IPT -A FORWARD -i ${WAN} -o ${LAN} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -i ${LAN} -o ${WAN} -j ACCEPT
$IPT -t nat -A POSTROUTING -o ${WAN} -j SNAT --to-source 192.168.0.51

# Allow traffic from the LAN
$IPT -A INPUT -i ${LAN} -j ACCEPT

# Allow traffic from the WAN that is an established connection
$IPT -A INPUT -i ${WAN} -m state --state RELATED,ESTABLISHED -j ACCEPT


## Filters
#
# Allow SSH 
$IPT -A INPUT -p tcp --dport ssh -j ACCEPT

# Allow DNS 
$IPT -A INPUT -p udp --dport domain -j ACCEPT

# Allow DHCP
$IPT -A INPUT -p udp --dport bootps -j ACCEPT

# Allow HTTP and HTTPS
$IPT -A INPUT -p tcp --dport http -j ACCEPT
$IPT -A INPUT -p tcp --dport https -j ACCEPT


## Port Forwarding
#
# Send HTTP and HTTPS to spacewalk server (10.10.10.11)
$IPT -t nat -A PREROUTING -p tcp --dport http -i ${WAN} -j DNAT --to 10.10.10.11
$IPT -t nat -A PREROUTING -p tcp --dport https -i ${WAN} -j DNAT --to 10.10.10.11


# Debugging

## Logging Blocked Packets
## Enable/Disable as needed
#$IPT -A INPUT -m limit --limit 50/minute -j LOG --log-level 7 --log-prefix "Dropped in: "
#$IPT -A OUTPUT -m limit --limit 50/minute -j LOG --log-level 7 --log-prefix "Dropped out: "
#$IPT -A FORWARD -m limit --limit 50/minute -j LOG --log-level 7 --log-prefix "Dropped fw: "

## Packet Tracing
## Enable/Disable as needed
#$IPT -t raw -A PREROUTING  -p tcp --dport 443 -j TRACE
#$IPT -t raw -A PREROUTING --destination 10.0.0.1 -p tcp --dport 25 -j TRACE


### Flush settings after 300 seconds if i lock myself out 
### Uncomment/comment this as needed
#sleep 300
#$IPT --flush 


