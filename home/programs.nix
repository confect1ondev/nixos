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
    modrinth-app
    prismlauncher
    
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

  # Enable programs
  programs.kitty.enable = true;
  programs.waybar.enable = true;
  programs.gh.enable = true;
}