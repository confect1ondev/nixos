{ config, pkgs, my, ... }:

{
  # GTK theme configuration
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "GoogleDot-Blue";
      size = 24;
      package = pkgs.google-cursor;
    };
  };

  # StartTree systemd service
  systemd.user.services.starttree = {
    Unit = {
      Description = "Serve StartTree startpage";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      WorkingDirectory = "${config.home.homeDirectory}/.config/StartTree";
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server ${toString my.ports.starttree}";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}