{ config, pkgs, my, ... }:

{
  # Link dotfiles
  home.file = {
    # Hyprland config is now managed by Nix in hyprland.nix
    # Copy all wallpapers to hypr config directory
    ".config/hypr/cyberpunk-car-girl.jpg".source = ../resources/wallpapers/cyberpunk-car-girl.jpg;
    ".config/hypr/lucy.png".source = ../resources/wallpapers/lucy.png;
    ".config/hypr/snowy_mountain.jpg".source = ../resources/wallpapers/snowy_mountain.jpg;
    ".config/hypr/dark-space.png".source = ../resources/wallpapers/dark-space.png;
    ".config/hypr/arknight.png".source = ../resources/wallpapers/arknight.png;
    ".config/StartTree" = {
      source = ../resources/web/starttree;
      recursive = true;
    };
  };
}