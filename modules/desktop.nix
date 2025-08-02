{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system (required for some apps even on Wayland)
  services.xserver.enable = true;

  # Disable ALL display managers completely
  services.xserver.autorun = false;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = false;
  services.xserver.displayManager.startx.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = config.my.keyboard.layout;
    variant = config.my.keyboard.variant;
  };
  
  # Boot to multi-user target (text mode) instead of graphical
  systemd.defaultUnit = lib.mkForce "multi-user.target";
  
  # Mask the display-manager service to prevent it from starting
  systemd.services.display-manager.enable = false;
  
  # Autologin ONLY on TTY1
  # All other TTYs will require normal login
  services.getty.autologinUser = lib.mkDefault null;
  
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""
        "${pkgs.util-linux}/bin/agetty --autologin ${config.my.username} --noclear --keep-baud tty1 115200,38400,9600 $TERM"
      ];
    };
  };
  
  # Reduce number of TTYs (default is 6, we only need 3)
  services.logind.extraConfig = ''
    NAutoVTs=3
  '';

  # Auto-start Hyprland on TTY1 only
  # This ensures Hyprlock is the first thing users see, and that it can't just be bypassed by flipping to a dif tty
  environment.loginShellInit = ''
    if [[ -z "$DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then      
      # Start Hyprland which will immediately show Hyprlock
      exec Hyprland
    fi
  '';

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  # Hint electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable touchpad support
  services.libinput.enable = true;
}