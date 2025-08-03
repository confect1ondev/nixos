{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ../../modules/common.nix
    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/networking.nix
    ../../modules/locale.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/virtualization.nix
    ../../modules/services.nix
    ../../modules/programs.nix
    ../../modules/security.nix
    ../../modules/tools.nix
    ../../modules/users.nix
    ../../modules/password-warning.nix
    ../../modules/tpm-enrollment.nix
  ];

  # Host-specific configuration
  networking.hostName = "laptop";
  
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