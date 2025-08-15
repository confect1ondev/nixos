{ config, pkgs, lib, ... }:

{
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

  # CoolerControl; dev is active and a super cool guy. Fantastic piece of software (as of Aug '25) :)
  programs.coolercontrol.enable = true;
  systemd.services.coolercontrol-liqctld.enable = false; # This conflicted with our other lctl scripting

  # mfw i need to take my own advice and disable unused stuff :)
  networking.modemmanager.enable = false;
  services.printing.enable = false; # lets be so real, this doesn't really work half the time anyway
}