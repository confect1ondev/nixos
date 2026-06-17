{ config, pkgs, my, lib, ... }:

{
  # Waypaper configuration
  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ${config.home.homeDirectory}/nixos/resources/wallpapers
    backend = hyprpaper
    monitors = ${my.desktop.waypaperMonitors}
    fill = fill
    sort = name
    color = #1e1e2e
    post_command = cp "$wallpaper" ~/.config/hypr/wallpaper.png
  '';
}