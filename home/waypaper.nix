{ config, pkgs, my, lib, ... }:

{
  # Mirror resources/wallpapers into ~/.config/wallpapers.
  # recursive = true links each file individually so dropping a new image
  # into resources/wallpapers is picked up on the next rebuild without edits.
  home.file.".config/wallpapers" = {
    source = ../resources/wallpapers;
    recursive = true;
  };

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