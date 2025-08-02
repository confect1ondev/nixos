{ config, pkgs, ... }:

{
  # Systemd user service to ensure wallpaper.png is writable
  systemd.user.services.wallpaper-init = {
    Unit = {
      Description = "Initialize writable wallpaper file";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "wallpaper-init" ''
        WALLPAPER_FILE="$HOME/.config/hypr/wallpaper.png"
        DEFAULT_WALLPAPER="$HOME/.config/wallpapers/arknight.png"
        
        # Ensure hypr directory exists
        mkdir -p "$HOME/.config/hypr"
        
        # If wallpaper.png doesn't exist or is not writable, fix it
        if [ ! -f "$WALLPAPER_FILE" ] || [ ! -w "$WALLPAPER_FILE" ]; then
          # Remove read-only file if it exists
          rm -f "$WALLPAPER_FILE"
          
          # Copy default wallpaper from wallpapers directory
          if [ -f "$DEFAULT_WALLPAPER" ]; then
            cp "$DEFAULT_WALLPAPER" "$WALLPAPER_FILE"
          else
            # If no default, create a placeholder
            echo "No default wallpaper found" > "$WALLPAPER_FILE.txt"
          fi
          
          # Make it writable
          chmod 644 "$WALLPAPER_FILE"
        fi
      ''}";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}