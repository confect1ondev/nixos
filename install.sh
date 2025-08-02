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

echo "Installation complete! You can now reboot."