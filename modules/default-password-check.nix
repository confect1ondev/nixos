{ config, lib, pkgs, ... }:

{
  # System service to check default password status and create a flag file
  systemd.services.default-password-check = {
    description = "Check if user is using default password";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = with pkgs; [ 
      shadow
      coreutils 
      gnugrep
      mkpasswd
    ];
    
    script = ''
      FLAG_FILE="/run/default-password-active"
      USERNAME="${config.my.username}"
      
      # Get the user's password hash
      USER_HASH=$(getent shadow "$USERNAME" | cut -d: -f2)
      
      # Check if we can read the hash and it's not locked
      if [[ -n "$USER_HASH" ]] && [[ "$USER_HASH" != "!" ]] && [[ "$USER_HASH" != "*" ]]; then
        # Extract salt and test if password is still "changeme"
        SALT=$(echo "$USER_HASH" | cut -d'$' -f3)
        if [[ -n "$SALT" ]]; then
          TEST_HASH=$(echo -n "changeme" | mkpasswd -s -m sha-512 -S "$SALT")
          
          if [[ "$TEST_HASH" == "$USER_HASH" ]]; then
            echo "Default password is active"
            touch "$FLAG_FILE"
          else
            echo "Password has been changed"
            rm -f "$FLAG_FILE" 2>/dev/null || true
          fi
        fi
      else
        echo "Could not check password status"
        # Don't create flag file if we can't verify
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  # User service to check the flag and notify
  systemd.user.services.default-password-notify = {
    description = "Notify user if default password is still active";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    
    path = with pkgs; [ 
      coreutils 
      libnotify 
    ];
    
    script = ''
      # Wait a moment for desktop to be ready
      sleep 5
      
      # Check the flag file created by the system service
      if [[ ! -f /run/default-password-active ]]; then
        echo "Default password not active (flag file not found)"
        exit 0
      fi
      
      # Send desktop notification
      notify-send -u critical -t 0 \
        "SECURITY WARNING: Default Password Active" \
        "Your account is still using the default password 'changeme'.\nPlease change it immediately with: passwd"
      
      echo "Default password warning notification sent"
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}