{ config, pkgs, lib, ... }:

{
  # System file manager (used by Hyprland $fileManager binding).
  programs.thunar.enable = true;

  # Required for various proprietary apps (steam, vscode, etc.). Personal apps
  # gated separately, but unfree on its own is harmless.
  nixpkgs.config.allowUnfree = true;

  # Runs generic-Linux dynamically-linked binaries (e.g. PlatformIO's bundled
  # cmake/toolchain/esptool under ~/.platformio) that don't know about /nix/store.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libusb1
    ncurses
    openssl
    expat
    xz
    libxml2
    libffi
    util-linux
  ];

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
    usbutils

    # Python interpreter (3.6+; nixpkgs default is currently 3.12)
    python3

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
