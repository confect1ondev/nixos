# NixOS Config

This is my personal NixOS setup with basically my whole system as-is. :)

![](divider.png)

### Automatic Install
1. Boot NixOS installer
2. Clone this repo
3. Run: `sudo ./install.sh`
4. Log in with default password `changeme`
5. Configuration is installed to `~/nixos-dev`

### Working with the Configuration
After installation, the configuration lives in `~/nixos-dev`. To make changes and rebuild:

```sh
# Edit files in ~/nixos-dev
cd ~/nixos-dev
# Make your changes...

# Then use one of these aliases to sync and rebuild:
nrs  # nixos-sync: Sync to /etc/nixos and rebuild switch
nrt  # nixos-test: Sync and rebuild test
nrb  # nixos-boot: Sync and rebuild boot
```

The aliases automatically:
- Sync your changes from `~/nixos-dev` to `/etc/nixos`
- Stage changes in git
- Run the appropriate nixos-rebuild command

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