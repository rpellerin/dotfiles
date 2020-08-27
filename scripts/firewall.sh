#!/bin/sh
#
# Simple Firewall configuration.
#
# Author: Romain Pellerin <contact@romainpellerin.eu>
#
# chkconfig: 2345 9 91
# description: Activates/Deactivates the firewall at boot time
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin

# Ports you may want to add
# 5432 PostgreSQL (remote or local tcp)
# 8080 livebox (remote tcp)
# 1194 OpenVPN (remote or local udp)
# 3128 Squid Proxy (remote or local tcp)
# 993 imap (remote tcp)
# 995 pop3 (remote tcp)
# 465 smtp (remote tcp)
# 631 ipp, printers (remote tcp)
# 51413 transmission peer port (local tcp and local udp)
# 9091 transmission webpage (local tcp)
# 389 LDAP (remote tcp and remote udp)
# 636 LDAPS (remote tcp and remote udp)
# 6667 irc (remote tcp)

# Services that the system will offer to the network
TCP_SERVICES="" # SSH can be written here, but that would allow it for anyone
UDP_SERVICES="68" # DHCP
# Services the system will use from the network
REMOTE_TCP_SERVICES="21 22 43 80 443 465 993" # ftp, ssh, whois, http, https, smtp (ssl), imap, openvpn
REMOTE_UDP_SERVICES="53 67 123 1194" # DNS ("whois" command for example), DHCP, ntp (time update), openvpn
# Network that will be used for remote mgmt
# (if undefined, everyone will be allowed)
NETWORK_MGMT=192.168.1.0/24
# Port used for the SSH service (locally), define this is you have setup a
# management network but remove it from TCP_SERVICES
SSH_PORT="22"

if ! [ -x /sbin/iptables ]; then
 exit 0
fi

##########################
# Start the Firewall rules
##########################

fw_start () {
# Default policy: forbid everything
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Logs
#iptables -A INPUT -j LOG
#iptables -A OUTPUT -j LOG

# Don't break established connections:
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Remote testing
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# Services
if [ -n "$TCP_SERVICES" ] ; then
for PORT in $TCP_SERVICES; do
 iptables -A INPUT -p tcp --dport ${PORT} -j ACCEPT
done
fi
if [ -n "$UDP_SERVICES" ] ; then
for PORT in $UDP_SERVICES; do
 iptables -A INPUT -p udp --dport ${PORT} -j ACCEPT
done
fi

# Remote services
if [ -n "$REMOTE_TCP_SERVICES" ] ; then
for PORT in $REMOTE_TCP_SERVICES; do
 iptables -A OUTPUT -p tcp --dport ${PORT} -j ACCEPT
done
fi
if [ -n "$REMOTE_UDP_SERVICES" ] ; then
for PORT in $REMOTE_UDP_SERVICES; do
 iptables -A OUTPUT -p udp --dport ${PORT} -j ACCEPT
done
fi
# Transmission-daemon
#iptables -A OUTPUT -m owner --gid-owner debian-transmission -j ACCEPT

# Peerflix
#iptables -A OUTPUT -m owner --gid-owner www-data -j ACCEPT

# OpenVPN
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
#iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# So are security package updates:
# Note: You can hardcode the IP address here to prevent DNS spoofing
# and to setup the rules even if DNS does not work but then you
# will not "see" IP changes for this service:
iptables -A OUTPUT -p tcp -d security.debian.org --dport 80 -j ACCEPT

# Remote management
if [ -n "$NETWORK_MGMT" ] ; then
 iptables -A INPUT -p tcp --src ${NETWORK_MGMT} --dport ${SSH_PORT} -j ACCEPT
else
 iptables -A INPUT -p tcp --dport ${SSH_PORT}  -j ACCEPT
fi

# Other
iptables -A OUTPUT -j REJECT

# Other network protections
# (some will only work with some kernel versions)
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
#echo 0 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
}

##########################
# Stop the Firewall rules
##########################

fw_stop () {
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
}

##########################
# Clear the Firewall rules
##########################

fw_clear () {
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
}

##########################
# Test the Firewall rules
##########################

fw_save () {
iptables-save > /etc/iptables.backup
}

fw_restore () {
if [ -e /etc/iptables.backup ]; then
 iptables-restore < /etc/iptables.backup
fi
}

fw_test () {
fw_save
sleep 30 && echo "Restore previous Firewall rules..." && fw_restore &
fw_stop
fw_start
}

case "$1" in
start|restart)
 echo -n "Starting firewall.."
 fw_stop
 fw_start
 echo "done."
 ;;
stop)
 echo -n "Stopping firewall.."
 fw_stop
 echo "done."
 ;;
clear)
 echo -n "Clearing firewall rules.."
 fw_clear
 echo "done."
 ;;
test)
 echo -n "Test Firewall rules..."
 fw_test
 echo -n "Previous configuration will be restore in 30 seconds"
 ;;
*)
 echo "Usage: $0 {start|stop|restart|clear|test}"
 echo "Be aware that stop drop all incoming/outgoing traffic !!!"
 exit 1
 ;;
esac
exit 0
