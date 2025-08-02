{ config, pkgs, lib, ... }:

let
  # Create our custom mako config
  makoConfig = pkgs.writeText "mako-config" ''
    # Global Configuration
    max-history=100
    sort=-time
    
    # Interaction settings
    actions=1
    default-timeout=10000
    ignore-timeout=1
    
    # Layout and appearance - enhanced for beauty
    font=Fira Code Medium 12
    width=440
    height=160
    margin=20
    padding=20,25
    border-size=3
    border-radius=16
    max-icon-size=64
    markup=1
    max-visible=5
    layer=overlay
    anchor=top-right
    
    # Enhanced Catppuccin Mocha color scheme
    background-color=#1E1E2EF0
    text-color=#CDD6F4
    border-color=#89B4FA
    progress-color=over #89B4FA
    
    # Icons
    icons=1
    icon-location=left
    text-alignment=left
    
    # Button interactions
    on-button-left=dismiss
    on-button-middle=none
    on-button-right=dismiss-all
    on-touch=dismiss
    
    # Sound notification
    on-notify=exec ${pkgs.pulseaudio}/bin/paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || true
    
    # Group by app
    group-by=app-name
    
    # Shadows for depth
    outer-margin=0,0,10,0
    
    # URGENCY LEVELS
    # Low urgency - subtle gray
    [urgency=low]
    background-color=#1E1E2EE0
    text-color=#A6ADC8
    border-color=#6C7086
    default-timeout=6000
    
    # Critical urgency - red alert theme, NEVER auto-dismiss
    [urgency=critical]
    background-color=#2D1B2BF0
    text-color=#F38BA8
    border-color=#F38BA8
    border-size=4
    default-timeout=0
    ignore-timeout=0
    
    # APP-SPECIFIC THEMES
    [app-name=Spotify]
    background-color=#1B2D1BF0
    border-color=#A6E3A1
    
    [app-name=spotify]
    background-color=#1B2D1BF0
    border-color=#A6E3A1
    
    [app-name=Discord]
    background-color=#2B1B2DF0
    border-color=#CBA6F7
    
    [app-name=discord]
    background-color=#2B1B2DF0
    border-color=#CBA6F7
    
    [app-name=Firefox]
    background-color=#2D2B1BF0
    border-color=#FAB387
    
    [app-name=firefox]
    background-color=#2D2B1BF0
    border-color=#FAB387
    
    [app-name=Code]
    background-color=#1B1D2DF0
    border-color=#74C7EC
    
    [app-name=code]
    background-color=#1B1D2DF0
    border-color=#74C7EC
  '';
  
  # Wrapper script that runs mako with our config
  makoWrapper = pkgs.writeShellScriptBin "mako" ''
    exec ${pkgs.mako}/bin/mako --config ${makoConfig} "$@"
  '';
in
{
  # Add our wrapped mako to packages
  home.packages = [ makoWrapper ];
  
  # Disable home-manager's mako service
  services.mako.enable = lib.mkForce false;
  
  # Create our own systemd service using the wrapper
  systemd.user.services.mako-custom = {
    Unit = {
      Description = "Lightweight notification daemon (custom)";
      Documentation = "man:mako(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      # Ensure we have Wayland display
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${makoWrapper}/bin/mako";
      RestartSec = 5;
      Restart = "always";
      # Ensure Wayland environment is available
      PassEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}