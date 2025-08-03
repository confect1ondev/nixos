# NixOS Config

This is my personal NixOS setup with basically my whole system as-is. :)

![](divider.png)

### Automatic Install
1. Boot NixOS installer
2. Clone this repo
3. Run: `sudo ./install.sh`
4. Log in with default password `changeme`

### Manual install

```sh
#Set hostname
export HOST=confect1on # or laptop

# Format disks with disko
echo "Formatting disks..."
nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode disko \
    --flake "${SCRIPT_DIR}#${HOST}"

# Install NixOS
echo "Installing NixOS..."
nixos-install --flake "${SCRIPT_DIR}#${HOST}" --no-root-passwd
```