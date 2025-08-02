{ config, pkgs, lib, ... }:

{
  # Enable TPM2 support
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;  # TPM2 PKCS#11 support
  security.tpm2.tctiEnvironment.enable = true;

  # Agenix configuration
  age.identityPaths = [ "/etc/nixos/bootstrap_agenix_key" ];

  age.secrets = {
    "${config.my.username}-password".file = ../secrets + "/${config.my.username}-password.age";
  };

  # Nix configuration
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    
    # Allow established connections
    allowedTCPPorts = [
      # Add any services that need external access here
    ];
    
    # Steam ports (defined in programs.nix with Steam config)
    # allowedTCPPorts = [ 18080 ];
    
    # Allow ping
    allowPing = true;
    
    # Log dropped packets for debugging
    logReversePathDrops = true;
    
    # Reject rather than drop packets
    rejectPackets = true;
  };
}