{ config, pkgs, lib, inputs, ... }:

{
  # System utilities
  # Firefox is now configured in firefox-policies.nix
  programs.thunar.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Game launchers
    inputs.hytale-launcher.packages.x86_64-linux.default

    # CLI tools from flakes
    inputs.witr.packages.x86_64-linux.default

    # Essential system tools
    tree
    file
    wget
    wl-clipboard
    pavucontrol
    home-manager
    libnotify  # For desktop notifications
    lsof
    pamixer
    gsettings-desktop-schemas

    # TPM2 tools
    tpm2-tss
    tpm2-tools

    # Development tools
    cargo
    rustc
    nodejs_24
    jdk
    glib
    gcc
    getent
    age
    zip
    unzip
    rar
    unrar
    xxd
    ent
    jq
    opencode
    claude-code
    gnupg
    pinentry-curses

    # Virtualization tools
    qemu
    libvirt
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    OVMF
    e2fsprogs

    # Cosmetic
    google-cursor
    juno-theme

    # Webcam tools
    v4l-utils       # Camera control utilities (v4l2-ctl)
    guvcview        # GUI to test and adjust webcam settings
    cameractrls     # Modern webcam settings GUI with Logitech support
  ];
}