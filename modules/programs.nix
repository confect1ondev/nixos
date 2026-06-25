{ config, pkgs, lib, ... }:

{
  # System file manager (used by Hyprland $fileManager binding).
  programs.thunar.enable = true;

  # Required for various proprietary apps (steam, vscode, etc.). Personal apps
  # gated separately, but unfree on its own is harmless.
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Essential CLI / system tools
    tree
    file
    wget
    wl-clipboard
    pavucontrol
    home-manager
    libnotify
    lsof
    pamixer
    gsettings-desktop-schemas
    glib
    getent

    # Standard sysadmin utilities
    age
    zip
    unzip
    xxd
    jq
    gnupg
    pinentry-curses

    # TPM2 (paired with modules/security.nix tpm2 enablement)
    tpm2-tss
    tpm2-tools

    # Virtualization (paired with modules/virtualization.nix)
    qemu
    libvirt
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    OVMF
    e2fsprogs
  ];
}
