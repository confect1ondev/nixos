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

    # Apps
    spotify
    monero-gui
    ledger-live-desktop
  ] ++ lib.optionals (hostName == "laptop") [
    wvkbd  # Virtual keyboard for touch
  ];

  # Enable programs
  programs.kitty.enable = true;
  programs.waybar.enable = true;
  programs.gh.enable = true;
}