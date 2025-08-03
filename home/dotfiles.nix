{ config, pkgs, my, ... }:

{
  # Link dotfiles
  home.file = {
    # Hyprland config is now managed by Nix in hyprland.nix
    # Copy all wallpapers to dedicated wallpapers directory
    ".config/wallpapers/cyberpunk-car-girl.png".source = ../resources/wallpapers/cyberpunk-car-girl.png;
    ".config/wallpapers/lucy.png".source = ../resources/wallpapers/lucy.png;
    ".config/wallpapers/snowy_mountain.png".source = ../resources/wallpapers/snowy_mountain.png;
    ".config/wallpapers/dark-space.png".source = ../resources/wallpapers/dark-space.png;
    ".config/wallpapers/arknight.png".source = ../resources/wallpapers/arknight.png;
    ".config/wallpapers/vertical.png".source = ../resources/wallpapers/vertical.png;
  };
}