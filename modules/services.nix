{ config, pkgs, lib, ... }:

let
  cfg = config.my.services;
in
{
  config = lib.mkMerge [
    {
      # Always-on, low-cost defaults
      services.blueman.enable = true;

      # mfw i need to take my own advice and disable unused stuff :)
      networking.modemmanager.enable = false;
      services.printing.enable = false; # lets be so real, this doesn't really work half the time anyway
    }

    (lib.mkIf cfg.mariadb.enable {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };

      # Lazy-start MariaDB on first socket connection (Arch-style).
      # Not true fd-passing — mariadb opens its own listener after start, so the
      # triggering connection may fail/stall; retry once the daemon is up.
      systemd.services.mysql.wantedBy = lib.mkForce [ ];
      systemd.tmpfiles.rules = [ "d /run/mysqld 0755 mysql mysql -" ];
      systemd.sockets.mysql = {
        description = "MariaDB lazy-start socket";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = "/run/mysqld/mysqld.sock";
          SocketMode = "0660";
          SocketUser = "mysql";
          SocketGroup = "mysql";
        };
      };
    })

    (lib.mkIf cfg.monero.enable {
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
          # Pruned mode - reduces blockchain size by ~7/8ths
          prune-blockchain=1
          sync-pruned-blocks=1

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

      # Wallet GUI ships with the daemon toggle so the user actually has a way to interact with it.
      environment.systemPackages = [ pkgs.monero-gui ];
    })

    (lib.mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
    })

    (lib.mkIf cfg.jellyfin.enable {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };
    })

    (lib.mkIf cfg.coolercontrol.enable {
      # CoolerControl; dev is active and a super cool guy. Fantastic piece of software (as of Aug '25) :)
      programs.coolercontrol.enable = true;
      systemd.services.coolercontrol-liqctld.enable = false; # This conflicted with our other lctl scripting
    })

    (lib.mkIf cfg.thunderbird.enable {
      programs.thunderbird.enable = true;
    })
  ];
}
