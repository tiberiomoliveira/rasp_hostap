#!/bin/bash
# example: initAp.sh wlan0 eth0
echo Starting $0 script

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 0
fi

# Initial wifi interface configuration
ip link set dev $1 up
ip address add 10.157.182.1/24 brd + dev $1

echo "Waiting a bit before start dhcpd..."
sleep 2

# Stop dhcpd
if [ "$(ps -e | grep dhcpd)" != "" ]; then
    killall dhcpd
fi

# Start DHCP, comment out / add relevant section
if [ "$(ps -e | grep dhcpd)" == "" ]; then
   dhcpd $1 &
fi

# Enable NAT
sysctl -w net.ipv4.ip_forward=1

iptables --flush
iptables -t nat --flush
iptables --delete-chain
iptables -t nat --delete-chain
iptables -t nat -A POSTROUTING -o $2 -j MASQUERADE

iptables -A FORWARD -i $2 -o $1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $1 -o $2 -j ACCEPT

# Block Torrent algo string using Boyer-Moore (bm)
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables -A FORWARD -m string --algo bm --string "/default.ida?" -j DROP
iptables -A FORWARD -m string --algo bm --string ".exe?/c+dir" -j DROP
iptables -A FORWARD -m string --algo bm --string ".exe?/c_tftp" -j DROP
# Block Torrent keys
iptables -A FORWARD -m string --algo kmp --string "peer_id" -j DROP
iptables -A FORWARD -m string --algo kmp --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo kmp --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo kmp --string "bittorrent-announce" -j DROP
iptables -A FORWARD -m string --algo kmp --string "announce.php?passkey=" -j DROP
# Block Distributed Hash Table (DHT) keywords
iptables -A FORWARD -m string --algo kmp --string "find_node" -j DROP
iptables -A FORWARD -m string --algo kmp --string "info_hash" -j DROP
iptables -A FORWARD -m string --algo kmp --string "get_peers" -j DROP
iptables -A FORWARD -m string --algo kmp --string "announce" -j DROP
iptables -A FORWARD -m string --algo kmp --string "announce_peers" -j DROP 

# Stop hostapd
if [ "$(ps -e | grep hostapd)" != "" ]; then
    killall hostapd
fi

# Start hostapd
hostapd -B /etc/hostapd/hostapd.conf 1> /dev/null

exit 1
EOF
