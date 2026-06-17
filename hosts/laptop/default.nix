{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ../../modules
  ];

  # Host-specific configuration
  networking.hostName = "laptop";

  my.username = "confect1on";
  my.userEmail = "me@confect1on.com";
  my.timezone = "America/Chicago";

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

  # Laptop-specific hardware configuration
  boot.kernelModules = [ "i915" ];

  services.thermald.enable = true;

  # Battery optimization
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      START_CHARGE_THRESH_BAT0 = 80;
      STOP_CHARGE_THRESH_BAT0 = 90;

      USB_AUTOSUSPEND = 1;
    };
  };
}