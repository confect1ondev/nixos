{ config, pkgs, lib, ... }:

{
  # NetworkManager
  networking.networkmanager.enable = true;
  
  # Don't wait for networkmanager
  systemd.services."NetworkManager-wait-online".enable = false;

  # Network bridge for VMs
  networking.bridges = {
    "virbr0" = {
      interfaces = [ ];
    };
  };
  
  networking.nat = {
    enable = true;
    internalInterfaces = [ "virbr0" ];
  };

  # Network diagnostics
  programs.mtr.enable = true;
  programs.nm-applet.enable = true;
}