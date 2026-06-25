{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./desktop.nix
    ../../modules
  ];

  networking.hostName = "laptop";

  my.username = "confect1on";
  my.userEmail = "me@confect1on.com";
  my.timezone = "America/Chicago";

  my.services = {
    steam.enable = true;
    mariadb.enable = true;
    monero.enable = true;
    jellyfin.enable = true;
    coolercontrol.enable = true;
    thunderbird.enable = true;
  };
}
