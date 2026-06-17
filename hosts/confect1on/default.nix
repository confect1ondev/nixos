{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ../../modules
  ];

  # Host-specific configuration
  networking.hostName = "confect1on";

  my.username = "confect1on";
  my.userEmail = "me@confect1on.com";
  my.timezone = "America/Chicago";

  my.desktop = {
    monitors = [
      "DP-1,3440x1440@240.00101,0x0,1"
      "HDMI-A-1,2560x1440@60,3440x-1050,1,transform,3"
    ];
    workspaces = [
      "1, monitor:HDMI-A-1"
      "2, monitor:DP-1"
    ];
    primaryMonitor = "DP-1";
    waypaperMonitors = "DP-1,HDMI-A-1";
  };

  my.hardware = {
    hasLiquidctl = true;
    hasOpenrgb = true;
  };
  
  # Auto-mount secondary storage drive
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/6f0e48d2-a8a1-4957-9a4d-760a92f50b14";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # Host-specific hardware configuration
  boot.kernelModules = [ "amdgpu" "i915" ];

  powerManagement.cpuFreqGovernor = "powersave";
  
  # OpenRGB for this specific system
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    liquidctl  # For controlling liquid coolers and other devices
    openrgb    # RGB lighting control
    proxmark3-rrg  # Proxmark3 client + flasher (Iceman/RRG fork)
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
  services.udev.packages = [ pkgs.liquidctl pkgs.proxmark3-rrg ];

  # Ollama with ROCm/AMD GPU support
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    loadModels = [ "huihui_ai/gemma3-abliterated:12b" ];
  };
}