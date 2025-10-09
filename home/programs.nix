{ config, pkgs, my, lib, hostName, ... }:

{
  home.packages = with pkgs; [
    # Development
    vscode
    lazygit
    
    # Creative
    krita
    
    # Media
    ffmpeg
    
    # Terminal & System
    kitty
    btop
    playerctl  # For controlling media players
    gsettings-desktop-schemas
    glib
    gtk3
    
    # Hyprland utilities
    waybar
    wofi
    swaylock-effects
    wlogout
    grim
    slurp
    swappy
    hyprpicker
    hyprpaper
    waypaper

    # Games
    lunar-client
    prismlauncher
    # --- Wrapped Modrinth launchers (no recursion, schemas included) ---
    (pkgs.writeShellScriptBin "ModrinthApp" ''
      set -euo pipefail

      export GDK_BACKEND="''${GDK_BACKEND:-x11}"

      # Use gsettings schemas from the gsettings-desktop-schemas package
      export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      
      # Also add to XDG_DATA_DIRS for good measure
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"
      
      export GTK_USE_PORTAL="''${GTK_USE_PORTAL:-1}"

      exec ${pkgs.modrinth-app}/bin/ModrinthApp "''$@"
    '')

    (pkgs.writeShellScriptBin "modrinth-app" ''exec ModrinthApp "''$@"'')
    # -------------------------------------------------------------------

    # --- Wrapped Java (similar to Modrinth) ---
    (pkgs.writeShellScriptBin "java-wrapped" ''
      set -euo pipefail

      export GDK_BACKEND="''${GDK_BACKEND:-x11}"

      # gsettings schemas
      export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"

      # include gtk/gsettings in XDG_DATA_DIRS
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"

      export GTK_USE_PORTAL="''${GTK_USE_PORTAL:-1}"

      exec ${pkgs.jdk17}/bin/java "''$@"
    '')
    # -------------------------------------------------------------------

    # Apps
    spotify
    jetbrains.idea-community-bin
    obsidian
    audacity
    monero-gui
    ledger-live-desktop
    tor-browser-bundle-bin
    blockbench
  ] ++ lib.optionals (hostName == "laptop") [
    wvkbd  # Virtual keyboard for touch
  ];

  dconf.enable = true;

  # Enable programs
  programs.kitty.enable = true;
  programs.waybar.enable = true;
  programs.gh.enable = true;
}