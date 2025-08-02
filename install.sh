#!/usr/bin/env bash
set -euo pipefail

# Check if HOST variable is set
if [[ -z "${HOST:-}" ]]; then
    echo "ERROR: HOST variable not set"
    echo "Usage: export HOST=laptop && sudo -E ./install.sh"
    echo "Note: Use 'sudo -E' to preserve environment variables"
    exit 1
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if host exists
if [[ ! -d "$SCRIPT_DIR/hosts/$HOST" ]]; then
    echo "ERROR: Host configuration not found: $HOST"
    echo "Available hosts:"
    find "$SCRIPT_DIR/hosts" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
    exit 1
fi

echo "Installing NixOS for host: $HOST"

# Format disks with disko
echo "Formatting disks..."
nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode disko \
    --flake "${SCRIPT_DIR}#${HOST}"

# Install NixOS
echo "Installing NixOS..."
nixos-install --flake "${SCRIPT_DIR}#${HOST}" --no-root-passwd

# Copy configuration to /mnt/etc/nixos for the installed system
echo "Copying configuration to installed system..."
if [[ ! -d /mnt ]]; then
    echo "ERROR: /mnt directory not found. Installation may have failed."
    exit 1
fi

mkdir -p /mnt/etc/nixos || {
    echo "ERROR: Failed to create /mnt/etc/nixos directory"
    exit 1
}

cp -r "${SCRIPT_DIR}"/* /mnt/etc/nixos/ || {
    echo "ERROR: Failed to copy configuration files"
    exit 1
}

chown -R root:root /mnt/etc/nixos || {
    echo "ERROR: Failed to set ownership on configuration files"
    exit 1
}

echo "Configuration successfully copied to /mnt/etc/nixos"

# Also copy to /etc/nixos if it exists (for immediate use)
if [[ -d /etc/nixos ]]; then
    echo "Copying configuration to current system..."
    cp -r "${SCRIPT_DIR}"/* /etc/nixos/ || echo "WARNING: Failed to copy to current system /etc/nixos"
    chown -R root:root /etc/nixos || echo "WARNING: Failed to set ownership on current system config"
fi

echo "Installation complete! You can now reboot."