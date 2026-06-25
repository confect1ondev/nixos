{ config, pkgs, inputs, ... }:

# Display layout (Hyprland monitors / workspaces) and the wofi app-menu
# entries shown when SUPER+SPACE is pressed.
{
  my.desktop = {
    monitors = [
      "DP-1,3440x1440@240.00101,0x0,1"
      "HDMI-A-1,2560x1440@60,3440x-1050,1,transform,3"
    ];
    workspaces = [
      "1, monitor:HDMI-A-1"
      "2, monitor:DP-1"
    ];
    primaryMonitor = "DP-1";
    waypaperMonitors = "DP-1,HDMI-A-1";
  };

  my.appMenu.apps = {
    "Spotify" = "${pkgs.spotify}/bin/spotify";
    "Steam" = "${pkgs.steam}/bin/steam";
    "Modrinth" = "modrinth-app";
    "Lunar Client" = "${pkgs.lunar-client}/bin/lunarclient";
    "Thunderbird" = "${pkgs.thunderbird}/bin/thunderbird";
    "Firefox" = "${pkgs.firefox}/bin/firefox";
    "VS Code" = "${pkgs.vscode}/bin/code";
    "Terminal" = "${pkgs.kitty}/bin/kitty";
    "Obsidian" = "${pkgs.obsidian}/bin/obsidian";
    "File Manager" = "${pkgs.xfce.thunar}/bin/thunar";
    "Virtual Machines" = "${pkgs.virt-manager}/bin/virt-manager";
    "Monero GUI" = "${pkgs.monero-gui}/bin/monero-wallet-gui";
    "Ledger GUI" = "${pkgs.ledger-live-desktop}/bin/ledger-live-desktop";
    "Hytale Launcher" = "${inputs.hytale-launcher.packages.x86_64-linux.default}/bin/hytale-launcher";
    "Signal" = "${pkgs.unstable.signal-desktop}/bin/signal-desktop";
    "Discord" = "${pkgs.vesktop}/bin/vesktop";
  };
}
