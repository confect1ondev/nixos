{ config, pkgs, my, lib, hostName, ... }:

{
  # Waypaper configuration
  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ${config.home.homeDirectory}/nixos/resources/wallpapers
    backend = hyprpaper
    monitors = ${if hostName == "confect1on" then "DP-1,HDMI-A-1" else "eDP-1"}
    fill = fill
    sort = name
    color = #1e1e2e
  '';
}