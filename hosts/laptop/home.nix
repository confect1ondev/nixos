{ config, pkgs, my, lib, inputs, ... }:

# Per-user home-manager packages for the laptop. Currently mirrors the desktop
# loadout so behavior is preserved across the restructure — prune freely if
# you don't actually use the heavyweight apps (IDEs, OBS, etc.) on the go.
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
    inputs.self.packages.x86_64-linux.claude-monitor
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
  ];

  programs.gh.enable = true;
}
