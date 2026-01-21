{ config, pkgs, my, lib, hostName, inputs, ... }:

let
lock-script = pkgs.writeShellScriptBin "lock-script" ''
  set -euo pipefail

  delay_until_uptime () {
    # sleep until system uptime is at least "$1" seconds
    target="$1"
    read -r up _ < /proc/uptime
    up=$\{up%%.*}
    if [ "$up" -lt "$target" ]; then
      sleep "$(( target - up ))"
    fi
  }

  is_alive () {
    # kill -0 checks if PID exists and is signallable
    kill -0 "$1" 2>/dev/null
  }

  ${lib.optionalString (hostName == "confect1on") ''
    # State file to track lock status
    LOCK_STATE_FILE="/tmp/hyprlock-state"

    # Retry a liquidctl command up to 3 times, checking lock state before each attempt
    # expected_state: "locked" or "unlocked"
    retry_liquidctl_if_state () {
      local expected_state="$1"
      local cmd="$2"
      local image="$3"

      for i in {1..3}; do
        # Check if state has changed
        if [ "$expected_state" = "locked" ] && [ ! -f "$LOCK_STATE_FILE" ]; then
          # Expected locked but now unlocked, abort
          return 1
        fi
        if [ "$expected_state" = "unlocked" ] && [ -f "$LOCK_STATE_FILE" ]; then
          # Expected unlocked but now locked, abort
          return 1
        fi

        if ${pkgs.liquidctl}/bin/liquidctl -m "Kraken" set lcd screen $cmd "$image" 2>/dev/null; then
          return 0
        fi
        sleep 1
      done
      return 1
    }

    # kick off a background worker that *may* set RED/LCD, but only if we're still locked then
    prelock_worker () (
      # wait for orgb and liqctl, but don't block hyprlock
      delay_until_uptime 3

      # only act if hyprlock is still running
      if is_alive "$1"; then
        ${pkgs.openrgb}/bin/openrgb --profile "RED" || true
        retry_liquidctl_if_state "locked" "gif" "${../resources/lcd/lock.png}" || true
      fi
    )
  ''}

  # Save lock start time (optional)
  date --iso-8601=seconds > /tmp/hyprlock-start || true

  ${lib.optionalString (hostName == "confect1on") ''
    # Mark as locked
    touch "$LOCK_STATE_FILE"
  ''}

  # Start hyprlock in background and capture PID
  ${pkgs.hyprlock}/bin/hyprlock &
  HLPID=$!

  ${lib.optionalString (hostName == "confect1on") ''
    # launch the conditional pre-lock worker with the hyprlock PID
    prelock_worker "$HLPID" >/dev/null 2>&1 &
  ''}

  # Wait for unlock
  wait "$HLPID" || true

  ${lib.optionalString (hostName == "confect1on") ''
    # Mark as unlocked
    rm -f "$LOCK_STATE_FILE"

    # On unlock, set lighting to blue and restore LCD
    ${pkgs.openrgb}/bin/openrgb --profile "BLUE" || true
    retry_liquidctl_if_state "unlocked" "gif" "${../resources/lcd/beacon.gif}" || true
  ''}
'';

  # Application menu script
  app-menu = pkgs.writeShellScriptBin "app-menu" ''
    # Define the list of applications as key-value pairs
    declare -A apps=(
      ["Spotify"]="${pkgs.spotify}/bin/spotify"
      ["Steam"]="${pkgs.steam}/bin/steam"
      ["Modrinth"]="modrinth-app"
      ["Lunar Client"]="${pkgs.lunar-client}/bin/lunarclient"
      ["Thunderbird"]="${pkgs.thunderbird}/bin/thunderbird"
      ["Firefox"]="${pkgs.firefox}/bin/firefox"
      ["VS Code"]="${pkgs.vscode}/bin/code"
      ["Terminal"]="${pkgs.kitty}/bin/kitty"
      ["Obsidian"]="${pkgs.obsidian}/bin/obsidian"
      ["File Manager"]="${pkgs.xfce.thunar}/bin/thunar"
      ["Virtual Machines"]="${pkgs.virt-manager}/bin/virt-manager"
      ["Monero GUI"]="${pkgs.monero-gui}/bin/monero-wallet-gui"
      ["Ledger GUI"]="${pkgs.ledger-live-desktop}/bin/ledger-live-desktop"
      ["Hytale Launcher"]="${inputs.hytale-launcher.packages.x86_64-linux.default}/bin/hytale-launcher"
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

  # Audio production setup script (yabridge, Wine VST directories)
  audio-setup = pkgs.writeShellScriptBin "audio-setup" ''
    set -euo pipefail

    echo "=== Audio Production Setup ==="
    echo ""

    # Create Wine prefix if it doesn't exist
    if [ ! -d "$HOME/.wine" ]; then
      echo "Creating Wine prefix..."
      WINEPREFIX="$HOME/.wine" ${pkgs.wineWowPackages.stable}/bin/wineboot --init
      echo "Waiting for Wine to finish setup..."
      sleep 5
    else
      echo "Wine prefix already exists."
    fi

    # Fix yabridge-host.exe path for NixOS
    echo "Setting up yabridge host..."
    mkdir -p "$HOME/.local/share/yabridge"
    ln -sf /etc/profiles/per-user/$USER/bin/yabridge-host.exe "$HOME/.local/share/yabridge/" 2>/dev/null || true
    ln -sf /etc/profiles/per-user/$USER/bin/yabridge-host.exe.so "$HOME/.local/share/yabridge/" 2>/dev/null || true
    ln -sf /etc/profiles/per-user/$USER/bin/yabridge-host-32.exe "$HOME/.local/share/yabridge/" 2>/dev/null || true
    ln -sf /etc/profiles/per-user/$USER/bin/yabridge-host-32.exe.so "$HOME/.local/share/yabridge/" 2>/dev/null || true

    # Create common VST directories
    echo "Creating VST directories..."
    mkdir -p "$HOME/.wine/drive_c/Program Files/Common Files/VST2"
    mkdir -p "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
    mkdir -p "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
    mkdir -p "$HOME/.wine/drive_c/Program Files/VstPlugins"
    mkdir -p "$HOME/.wine/drive_c/Program Files (x86)/Common Files/VST2"
    mkdir -p "$HOME/.wine/drive_c/Program Files (x86)/Common Files/VST3"
    mkdir -p "$HOME/.wine/drive_c/Program Files (x86)/Steinberg/VstPlugins"
    mkdir -p "$HOME/.wine/drive_c/Program Files (x86)/VstPlugins"

    # Create native Linux VST directories for yabridge
    mkdir -p "$HOME/.vst"
    mkdir -p "$HOME/.vst3"

    # Add VST directories to yabridge
    echo "Configuring yabridge..."
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST2" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files/VstPlugins" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files (x86)/Common Files/VST2" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files (x86)/Common Files/VST3" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files (x86)/Steinberg/VstPlugins" 2>/dev/null || true
    ${pkgs.yabridgectl}/bin/yabridgectl add "$HOME/.wine/drive_c/Program Files (x86)/VstPlugins" 2>/dev/null || true

    # Sync yabridge
    echo "Syncing yabridge..."
    ${pkgs.yabridgectl}/bin/yabridgectl sync

    # Show status
    echo ""
    echo "=== Setup Complete ==="
    echo ""
    ${pkgs.yabridgectl}/bin/yabridgectl status

    echo ""
    echo "To install Windows VST plugins:"
    echo "  1. Download the VST installer (.exe)"
    echo "  2. Run: wine /path/to/installer.exe"
    echo "  3. Install to one of the directories above"
    echo "  4. Run: yabridgectl sync"
    echo ""
    echo "Your bridged plugins will appear in ~/.vst and ~/.vst3"
  '';

in
{
  # Add scripts to user packages
  home.packages = [
    lock-script
    app-menu
    wallpaper-switcher
    screenshot
    audio-setup
  ];
}