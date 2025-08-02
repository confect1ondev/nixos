{ config, pkgs, my, ... }:

{
  imports = [
    ./programs.nix
    ./shell.nix
    ./desktop.nix
    ./dotfiles.nix
    ./hyprland.nix
    ./wofi.nix
    ./scripts.nix
    ./kitty.nix
    ./mako.nix
    ./waybar.nix
    ./starship.nix
    ./firefox.nix
    ./waypaper.nix
  ];

  # Base home configuration
  home.stateVersion = "25.05";
  
  # Enable systemd services
  systemd.user.startServices = "sd-switch";
}