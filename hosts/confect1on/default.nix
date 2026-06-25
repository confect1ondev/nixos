{ config, pkgs, ... }:

# Host identity + which opinionated services are turned on.
# Physical hardware lives in ./hardware.nix, display/app-menu in ./desktop.nix,
# personal home-manager packages in ./home.nix.
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./desktop.nix
    ../../modules
  ];

  networking.hostName = "confect1on";

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
