{ config, pkgs, ... }:

# Single eDP panel + isLaptop flag (enables hyprgrass touch gestures and
# virtual keyboard). No app-menu entries by default — fill in my.appMenu.apps
# if you want SUPER+SPACE to show a launcher here.
{
  my.desktop = {
    isLaptop = true;
    monitors = [ "eDP-1,1920x1080@60,0x0,1" ];
    workspaces = [
      "1, monitor:eDP-1"
      "2, monitor:eDP-1"
      "3, monitor:eDP-1"
      "4, monitor:eDP-1"
      "5, monitor:eDP-1"
      "6, monitor:eDP-1"
      "7, monitor:eDP-1"
      "8, monitor:eDP-1"
      "9, monitor:eDP-1"
      "10, monitor:eDP-1"
    ];
    primaryMonitor = "eDP-1";
    waypaperMonitors = "eDP-1";
    inputSensitivity = 0.2;
  };
}
