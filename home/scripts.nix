{ config, pkgs, my, lib, hostName, ... }:

let
  # Lock script with conditional OpenRGB support
  lock-script = pkgs.writeShellScriptBin "lock-script" ''
    ${lib.optionalString (hostName == "confect1on") ''
      # Set orientation since it inits wrong
      ${pkgs.liquidctl}/bin/liquidctl -m \"Kraken\" set lcd screen orientation 270 &

      # Set red lighting before lock (desktop only)
      ${pkgs.openrgb}/bin/openrgb --profile "RED" &
      
      # Set Kraken LCD to lock screen
      ${pkgs.liquidctl}/bin/liquidctl -m "Kraken" set lcd screen gif ${../resources/lcd/lock.png} &
    ''}
    
    # Save lock start time (optional, for failed login tracking, very fancy :3)
    date --iso-8601=seconds > /tmp/hyprlock-start
    
    # Run Hyprlock
    ${pkgs.hyprlock}/bin/hyprlock
    
    ${lib.optionalString (hostName == "confect1on") ''
      # When hyprlock exits (on unlock), set lighting to blue (desktop only)
      ${pkgs.openrgb}/bin/openrgb --profile "BLUE" &
      
      # Set Kraken LCD back to beacon gif
      ${pkgs.liquidctl}/bin/liquidctl -m "Kraken" set lcd screen gif ${../resources/lcd/beacon.gif} &
    ''}
  '';

  # Application menu script
  app-menu = pkgs.writeShellScriptBin "app-menu" ''
    # Define the list of applications as key-value pairs
    declare -A apps=(
      ["Spotify"]="${pkgs.spotify}/bin/spotify"
      ["Steam"]="${pkgs.steam}/bin/steam"
      ["Modrinth"]="GDK_BACKEND=x11 ${pkgs.modrinth-app}/bin/ModrinthApp"
      ["Lunar Client"]="${pkgs.lunar-client}/bin/lunar-client"
      ["Firefox"]="${pkgs.firefox}/bin/firefox"
      ["VS Code"]="${pkgs.vscode}/bin/code"
      ["Terminal"]="${pkgs.kitty}/bin/kitty"
      ["File Manager"]="${pkgs.xfce.thunar}/bin/thunar"
      ["Virtual Machines"]="${pkgs.virt-manager}/bin/virt-manager"
      ["Monero GUI"]="${pkgs.monero-gui}/bin/monero-wallet-gui"
      ["Ledger GUI"]="${pkgs.ledger-live-desktop}/bin/ledger-live-desktop"
    )
    
    # Construct the list of application names for wofi
    app_list=$(printf "%s\n" "''${!apps[@]}" | sort)
    
    # Prompt user to select an application
    selected_app=$(echo -e "$app_list" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Select Application:")
    
    # If an application is selected, execute it
    if [ -n "$selected_app" ]; then
      # Get the corresponding command
      app_command=''${apps["$selected_app"]}
      if [ -n "$app_command" ]; then
        # Execute the selected application
        eval "$app_command" &
      fi
    fi
  '';

  # Simple wallpaper switcher that launches waypaper
  wallpaper-switcher = pkgs.writeShellScriptBin "wallpaper-switcher" ''
    # Launch waypaper with the wallpapers directory
    ${pkgs.waypaper}/bin/waypaper --folder ~/.config/wallpapers --backend hyprpaper
  '';

  # Screenshot helper script
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    case "$1" in
      full)
        ${pkgs.grim}/bin/grim -g "0,0 3440x1440"
        ;;
      area)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)"
        ;;
      *)
        echo "Usage: screenshot [full|area]"
        exit 1
        ;;
    esac
  '';

in
{
  # Add scripts to user packages
  home.packages = [
    lock-script
    app-menu
    wallpaper-switcher
    screenshot
  ];
}