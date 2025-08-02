#!/usr/bin/env bash

set -e

echo "[×] Disabling Wi-Fi to Ethernet sharing and restoring default state..."

WIFI_IFACE="wlan0"
ETH_IFACE="enp0s31f6"
DNSMASQ_CONF="/etc/dnsmasq.conf"

# Step 1: Reset Ethernet interface
echo "[*] Flushing IP and bringing down $ETH_IFACE..."
sudo ip addr flush dev "$ETH_IFACE"
sudo ip link set "$ETH_IFACE" down

# Step 2: Disable IP forwarding
echo "[*] Disabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=0

# Step 3: Remove iptables NAT and forward rules
echo "[*] Removing iptables rules with comment 'wifi-share'..."
sudo iptables-save | grep 'wifi-share' | sed 's/-A/-D/' | sort -u | while read -r rule; do
  echo "[-] Removing rule: $rule"
  sudo iptables $rule || echo "[!] Rule already removed or failed: $rule"
done

# Step 4: Clean dnsmasq config
echo "[*] Removing dnsmasq config block (if present)..."
if grep -q "# === Wi-Fi to Ethernet Sharing ===" "$DNSMASQ_CONF"; then
  sudo sed -i '/# === Wi-Fi to Ethernet Sharing ===/,+5d' "$DNSMASQ_CONF"
  echo "[✓] dnsmasq config block removed."
else
  echo "[=] No dnsmasq sharing block found."
fi

# Step 5: Disable and stop dnsmasq
echo "[*] Disabling and stopping dnsmasq..."
sudo systemctl disable --now dnsmasq || echo "[!] dnsmasq already disabled."

# Step 6: Confirm systemd-resolved is active
echo "[*] Ensuring systemd-resolved is running..."
sudo systemctl enable --now systemd-resolved

echo "[✓] Teardown complete. System DNS is back to systemd-resolved. Ethernet is clean and ready."
