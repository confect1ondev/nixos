{ config, pkgs, lib, ... }:

{
  # Enable CUPS to print documents
  services.printing.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Monero daemon
  services.monero = {
    enable = true;
    dataDir = "/var/lib/monero";

    rpc = {
      address = "127.0.0.1";  # only local access
      port = config.my.ports.moneroRpc;
      restricted = false;     # WARNING: Full wallet RPC access - secure for localhost only
    };

    extraConfig = ''
      hide-my-port=1
      no-igd=1
      enable-dns-blocklist=1
      db-sync-mode=safe
    '';
  };

  # Bluetooth
  services.blueman.enable = true;
}