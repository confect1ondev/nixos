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
    openrgb    # RGB lighting control
  ];
  
  # Liquidctl configuration (mainly to init NZXT Kraken)
  systemd.services.liquidctl-init = {
    description = "Initialize Liquidctl";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "liquidctl-init" ''
        # Initialize all liquidctl devices
        ${pkgs.liquidctl}/bin/liquidctl initialize all || true

        # Wait for devices to be ready after initialization
        sleep 2

        # Set Kraken LCD orientation (fail silently if device not found)
        ${pkgs.liquidctl}/bin/liquidctl -m "Kraken" set lcd screen orientation 270 || true
      '';
    };
  };
  
  # Set up udev rules for liquidctl (non-root access)
  services.udev.packages = [ pkgs.liquidctl ];

  # Ollama with ROCm/AMD GPU support
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    loadModels = [ "huihui_ai/gemma3-abliterated:12b" ];
  };
}