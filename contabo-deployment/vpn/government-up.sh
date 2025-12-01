#!/bin/bash
# Script to log the VPN-assigned IP address
# This runs when VPN connection is established

LOGFILE="/var/log/openvpn/vpn-assigned-ip.log"

echo "========================================" >> $LOGFILE
echo "VPN Connected: $(date)" >> $LOGFILE
echo "Interface: $dev" >> $LOGFILE
echo "Local IP (VPN assigned): $ifconfig_local" >> $LOGFILE
echo "Remote IP (VPN gateway): $ifconfig_remote" >> $LOGFILE
echo "Routes pushed:" >> $LOGFILE
ip route | grep $dev >> $LOGFILE
echo "========================================" >> $LOGFILE

# Send notification (optional)
echo "VPN Connected - Assigned IP: $ifconfig_local" | logger -t openvpn-government

# IMPORTANT: This is the IP that IT needs to whitelist!
echo "⚠️  WHITELIST THIS IP: $ifconfig_local" >> $LOGFILE
