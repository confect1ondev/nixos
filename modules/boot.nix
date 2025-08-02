{ config, pkgs, lib, ... }:

{
  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;  # Keep only 5 generations in boot menu
    editor = false;
  };
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable systemd in initrd for TPM2 support
  boot.initrd.systemd.enable = true;

  # LUKS configuration using partition label
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/luks";
    allowDiscards = true;
    bypassWorkqueues = true;
    # Try TPM2 first, fall back to password
    crypttabExtraOpts = [ "tpm2-device=auto" "token-timeout=10" ];
  };
  
  # Enable TPM2 device availability in initrd
  boot.initrd.availableKernelModules = [ "tpm_tis" "tpm_crb" "nvme" "xhci_pci" "usbhid"];
  
  # Enable KVM for virtualization
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
}