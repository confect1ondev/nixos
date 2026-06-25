{ config, pkgs, ... }:

# Physical-machine config for the laptop: intel GPU, thermald, TLP battery
# governor with conservative charge thresholds.
{
  boot.kernelModules = [ "i915" ];

  services.thermald.enable = true;

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
