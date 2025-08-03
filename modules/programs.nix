{ config, pkgs, lib, ... }:

{
  # System utilities
  # Firefox is now configured in firefox-policies.nix
  programs.thunar.enable = true;
  programs.coolercontrol.enable = true;

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
    # Essential system tools
    tree
    file
    wget
    wl-clipboard
    pavucontrol
    home-manager
    libnotify  # For desktop notifications

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
    age

    # Virtualization tools
    qemu
    libvirt
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    OVMF

    # Cosmetic
    google-cursor
    juno-theme
  ];
}