{ config, pkgs, ... }:

# Physical-machine config: kernel modules, filesystems, power, hardware-specific
# services + their packages. Everything here is tied to *this* desktop's
# physical setup (NZXT Kraken AIO, OpenRGB motherboard, AMD GPU, etc.).
{
  my.hardware = {
    hasLiquidctl = true;
    hasOpenrgb = true;
  };

  # Secondary storage drive
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/6f0e48d2-a8a1-4957-9a4d-760a92f50b14";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  boot.kernelModules = [ "amdgpu" "i915" ];

  # intel_pstate active-mode "powersave" governor — dynamic HWP scaling.
  # Idle → low clocks; load → full turbo. See discussion in commit history.
  powerManagement.cpuFreqGovernor = "powersave";

  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };

  environment.systemPackages = with pkgs; [
    liquidctl       # Liquid cooler / Kraken control
    openrgb         # RGB lighting control
    proxmark3-rrg   # Proxmark3 client + flasher (Iceman/RRG fork)
  ];

  # Initialize Kraken on boot and set LCD orientation.
  systemd.services.liquidctl-init = {
    description = "Initialize Liquidctl";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "liquidctl-init" ''
        ${pkgs.liquidctl}/bin/liquidctl initialize all || true
        sleep 2
        ${pkgs.liquidctl}/bin/liquidctl -m "Kraken" set lcd screen orientation 270 || true
      '';
    };
  };

  # Non-root USB access for liquidctl + proxmark
  services.udev.packages = [ pkgs.liquidctl pkgs.proxmark3-rrg ];

  # Ollama with ROCm/AMD GPU support
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    loadModels = [ "huihui_ai/gemma3-abliterated:12b" ];
  };
}
