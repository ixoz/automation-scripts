#!/bin/bash

# Cloudflare DNS
DNS_SERVERS="1.1.1.1 1.0.0.1"

# Get active connection and device
CONN_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | head -n 1 | cut -d: -f1)
DEVICE=$(nmcli -t -f DEVICE,STATE device | grep ':connected' | cut -d: -f1 | head -n 1)

if [ -z "$CONN_NAME" ] || [ -z "$DEVICE" ]; then
  echo "No active network connection found."
  exit 1
fi

echo "Updating DNS for connection: $CONN_NAME (Device: $DEVICE)"

# Disable automatic DNS from DHCP
nmcli connection modify "$CONN_NAME" ipv4.ignore-auto-dns yes

# Set Cloudflare DNS
nmcli connection modify "$CONN_NAME" ipv4.dns "$DNS_SERVERS"

# Reapply settings safely without full disconnect
nmcli connection down "$CONN_NAME" || true
nmcli device connect "$DEVICE"

# Show confirmation
echo "DNS updated. Current DNS settings:"
nmcli dev show "$DEVICE" | grep DNS
