{ config, pkgs, lib, ... }:

{
  # Virtualization configuration
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ 
            pkgs.OVMFFull.fd
            (pkgs.OVMF.override {
              secureBoot = true;
            })
          ];
        };
      };
      extraConfig = ''
        nvram = [
          "/run/libvirt/nix-ovmf/OVMF_CODE.ms.fd:/run/libvirt/nix-ovmf/OVMF_VARS.ms.fd",
          "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"
        ]
      '';
    };
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
      # Prune old images automatically
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Virtual machines
  programs.virt-manager.enable = true;
  # Don't worry about suspending/resuming guests on shutdown/boot
  systemd.services.libvirt-guests.enable = false;
  
  # Socket activation for Docker
  systemd.services.docker = {
    wantedBy = lib.mkForce [ ];  # Remove from boot targets
  };
  
  # Ensure Docker socket is enabled
  systemd.sockets.docker = {
    wantedBy = [ "sockets.target" ];
  };
}