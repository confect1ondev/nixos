#!/usr/bin/env bash

set -e

echo "[+] Starting Wi-Fi → Ethernet sharing setup..."

WIFI_IFACE="wlan0"
ETH_IFACE="enp0s31f6"
GATEWAY_IP="192.168.7.1"
SUBNET="192.168.7.0/24"
DNSMASQ_CONF="/etc/dnsmasq.conf"

echo "[*] Assigning static IP $GATEWAY_IP to $ETH_IFACE..."
sudo ip addr flush dev "$ETH_IFACE"
sudo ip addr add "$GATEWAY_IP/24" dev "$ETH_IFACE"
sudo ip link set "$ETH_IFACE" up

echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

echo "[*] Setting up iptables NAT and forwarding rules..."
sudo iptables -t nat -C POSTROUTING -o "$WIFI_IFACE" -j MASQUERADE 2>/dev/null || \
  sudo iptables -t nat -A POSTROUTING -o "$WIFI_IFACE" -j MASQUERADE -m comment --comment "wifi-share"

sudo iptables -C FORWARD -i "$ETH_IFACE" -o "$WIFI_IFACE" -j ACCEPT 2>/dev/null || \
  sudo iptables -A FORWARD -i "$ETH_IFACE" -o "$WIFI_IFACE" -j ACCEPT -m comment --comment "wifi-share"

sudo iptables -C FORWARD -i "$WIFI_IFACE" -o "$ETH_IFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
  sudo iptables -A FORWARD -i "$WIFI_IFACE" -o "$ETH_IFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT -m comment --comment "wifi-share"

echo "[*] Checking dnsmasq config..."
if ! grep -q "# === Wi-Fi to Ethernet Sharing ===" "$DNSMASQ_CONF"; then
  echo "[*] Appending dnsmasq sharing config..."
  sudo tee -a "$DNSMASQ_CONF" > /dev/null <<EOF

# === Wi-Fi to Ethernet Sharing ===
interface=$ETH_IFACE
bind-interfaces
dhcp-range=192.168.7.50,192.168.7.150,12h
dhcp-option=3,$GATEWAY_IP
dhcp-option=6,1.1.1.1
EOF
else
  echo "[=] dnsmasq config already contains sharing settings."
fi

echo "[*] Waiting for $ETH_IFACE to be up and have a carrier..."
for i in {1..5}; do
  if [[ "$(cat /sys/class/net/$ETH_IFACE/carrier 2>/dev/null)" == "1" ]]; then
    echo "  ...carrier detected!"
    break
  fi
  echo "  ...waiting for carrier ($i)"
  sleep 1
done

echo "[*] Restarting dnsmasq..."
sudo systemctl restart dnsmasq

echo "[✓] Wi-Fi sharing is now active! Ethernet clients should receive IPs and access the internet."
