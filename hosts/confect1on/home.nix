{ config, pkgs, my, lib, inputs, ... }:

# Per-user (home-manager) personal apps for confect1on.
# Everything here is "binary in PATH + maybe a dotfile" — no system glue.
# System-level toggles (Steam firewall, Monero daemon, etc.) live in
# ./default.nix under my.services.*.
{
  home.packages = with pkgs; [
    # Communications
    unstable.signal-desktop
    zoom-us
    unstable.vesktop

    # Daily-driver apps
    spotify
    obsidian
    tor-browser-bundle-bin

    # Dev — IDEs, CLI tooling
    vscode
    lazygit
    jetbrains.idea-community-bin
    inputs.claude-code-nix.packages.x86_64-linux.default
    inputs.witr.packages.x86_64-linux.default
    opencode

    # Dev — toolchains
    cargo
    rustc
    nodejs_24
    unstable.jdk25
    gcc

    # Creative
    krita
    blockbench
    audacity

    # Game launchers
    lunar-client
    prismlauncher
    mcpelauncher-ui-qt
    inputs.hytale-launcher.packages.x86_64-linux.default

    # Crypto
    ledger-live-desktop

    # misc
    rar
    ent

    # Cosmetic
    google-cursor
    juno-theme

    # Webcam tools
    v4l-utils
    guvcview
    cameractrls

    # Wrapped Modrinth launcher — pulls in GTK schemas to avoid runtime errors.
    (pkgs.writeShellScriptBin "ModrinthApp" ''
      set -euo pipefail
      export GDK_BACKEND="''${GDK_BACKEND:-x11}"
      export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"
      export GTK_USE_PORTAL="''${GTK_USE_PORTAL:-1}"
      exec ${pkgs.modrinth-app}/bin/ModrinthApp "''$@"
    '')
    (pkgs.writeShellScriptBin "modrinth-app" ''exec ModrinthApp "''$@"'')

    # Java wrapper with GTK schema env — needed for some legacy Minecraft launchers.
    (pkgs.writeShellScriptBin "java-wrapped" ''
      set -euo pipefail
      export GDK_BACKEND="''${GDK_BACKEND:-x11}"
      export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"
      export GTK_USE_PORTAL="''${GTK_USE_PORTAL:-1}"
      exec ${pkgs.jdk17}/bin/java "''$@"
    '')
  ];

  programs.gh.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi  # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
