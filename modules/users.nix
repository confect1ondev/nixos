{ config, pkgs, lib, ... }:

{
  # Define a user account
  users.users.${config.my.username} = {
    isNormalUser = true;
    description = config.my.username;
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "video"     # GPU access
      "audio"     # Audio access
      "input"    # Input devices (keyboard, mouse, etc)
      "render"    # GPU rendering
      "libvirtd"  # Virtualization access
      "kvm"       # KVM access
    ];
    # Use age-encrypted password hash
    hashedPasswordFile = config.age.secrets."${config.my.username}-password".path;
    packages = with pkgs; [
      # should use home manager instead :)
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";
}