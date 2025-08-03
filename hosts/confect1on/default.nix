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
    ../../modules/users.nix
    ../../modules/password-warning.nix
    ../../modules/tpm-enrollment.nix
  ];

  # Host-specific configuration
  networking.hostName = "confect1on";
  
  # Host-specific hardware configuration
  boot.kernelModules = [ "amdgpu" "i915" ];
  
  # OpenRGB for this specific system
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    liquidctl  # For controlling liquid coolers and other devices
  ];
  
  # Liquidctl configuration for NZXT Kraken
  systemd.services.liquidctl-init = {
    description = "Initialize NZXT Kraken 2023 Elite";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.liquidctl}/bin/liquidctl initialize all";
    };
  };
  
  # Set up udev rules for liquidctl (non-root access)
  services.udev.packages = [ pkgs.liquidctl ];
}