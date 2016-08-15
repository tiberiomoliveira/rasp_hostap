#!/bin/bash
# example: arch_rasp
echo Starting $0 script

if [ "$#" -ne 0 ]; then
    echo "No parameter is required"
    exit 0
fi

# Create a iptables rules file
if [ -a /etc/iptables/iptables.rules ]; then
    iptables-save >> /etc/iptables/iptables.rules
else
    echo "iptables.rules doesn't exist."
    exit 0
fi

# Enable iptables initialization on boot
systemctl enable iptables

# Enable hostap initialization on boot
systemctl enable hostapd

# Enable dhcpd initialization on boot
systemctl enable dhcpd4

exit 1
EOF
