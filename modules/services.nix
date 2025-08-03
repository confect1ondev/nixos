{ config, pkgs, lib, ... }:

{
  # Enable CUPS to print documents
  services.printing.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Monero daemon with enhanced security
  services.monero = {
    enable = true;
    dataDir = "/var/lib/monero";

    rpc = {
      address = "127.0.0.1";  # only local access
      port = config.my.ports.moneroRpc;
      restricted = true;      # Restricted RPC mode - safer default
    };

    extraConfig = ''
      # Privacy and security settings
      hide-my-port=1
      no-igd=1
      enable-dns-blocklist=1
      db-sync-mode=safe
      
      # Additional security hardening
      disable-rpc-ban=0
      confirm-external-bind=0
      
      # Performance and stability
      max-connections-per-ip=1
      
      # Optional: Enable RPC authentication
      # rpc-login=username:password
    '';
  };
  
  # Ensure Monero data directory has proper permissions
  systemd.services.monero.serviceConfig = {
    # Run with reduced privileges
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    NoNewPrivileges = true;
    ReadWritePaths = [ "/var/lib/monero" ];
  };

  # Bluetooth
  services.blueman.enable = true;
}