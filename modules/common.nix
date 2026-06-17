{ lib, ... }:

{
  options.my = {
    # --- Must be set per host ---
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary user account name";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "User email for git and other configurations";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      description = "System timezone";
    };

    desktop = {
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Hyprland monitor configuration strings";
      };

      workspaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Hyprland workspace assignment strings";
      };

      primaryMonitor = lib.mkOption {
        type = lib.types.str;
        description = "Primary monitor name (used for hyprlock labels, etc.)";
      };

      waypaperMonitors = lib.mkOption {
        type = lib.types.str;
        description = "Comma-separated monitor names for waypaper config";
      };

      # --- Sane defaults ---
      isLaptop = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable laptop-specific features (touch gestures, virtual keyboard, etc.)";
      };

      inputSensitivity = lib.mkOption {
        type = lib.types.number;
        default = -1;
        description = "Mouse/touchpad input sensitivity for Hyprland";
      };
    };

    # --- Sane defaults ---
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };

      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard variant";
      };
    };

    ports = {
      starttree = lib.mkOption {
        type = lib.types.port;
        default = 8085;
        description = "Port for StartTree start page service";
      };

      moneroRpc = lib.mkOption {
        type = lib.types.port;
        default = 18081;
        description = "Port for Monero RPC service";
      };
    };

    hardware = {
      hasLiquidctl = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this host has liquidctl-compatible devices (Kraken AIO, etc.)";
      };

      hasOpenrgb = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this host has OpenRGB-compatible RGB hardware";
      };
    };
  };
}