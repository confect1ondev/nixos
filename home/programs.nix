{ config, pkgs, my, lib, ... }:

{
  home.packages = with pkgs; [
    # Media (codec swiss-army; pulled in by lots of stuff)
    ffmpeg

    # Terminal & system
    kitty
    btop
    playerctl
    gsettings-desktop-schemas
    glib
    gtk3

    # Hyprland utilities — core to the WM functioning
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

    # Bluetooth manager (paired with services.blueman in modules/services.nix)
    blueman
  ] ++ lib.optionals (my.desktop.isLaptop) [
    wvkbd  # Virtual keyboard for touch
  ];

  dconf.enable = true;

  programs.kitty.enable = true;
  programs.waybar.enable = true;
}
