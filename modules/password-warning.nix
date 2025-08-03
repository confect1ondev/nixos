{ config, lib, pkgs, ... }:

{
  # System service to check default password status and create a flag file
  systemd.services.password-warning-check = {
    description = "Check if user is using default password";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = with pkgs; [ 
      getent
      shadow
      coreutils 
      gnugrep
      gnused
      mkpasswd
    ];
    
    script = ''
      FLAG_FILE="/run/default-password-active"
      USERNAME="${config.my.username}"
      
      # Get the user's password hash
      USER_HASH=$(getent shadow "$USERNAME" | cut -d: -f2)
      
      # Debug output
      echo "Checking password for user: $USERNAME"
      echo "Hash prefix: $(echo "$USER_HASH" | cut -c1-3)"
      
      # Check if we can read the hash and it's not locked
      if [[ -n "$USER_HASH" ]] && [[ "$USER_HASH" != "!" ]] && [[ "$USER_HASH" != "*" ]]; then
        # Determine hash type and test accordingly
        if [[ "$USER_HASH" =~ ^\$6\$ ]]; then
          # SHA-512 hash
          echo "Detected SHA-512 hash"
          # Extract the salt (between the second and third $)
          # Format is $6$salt$hash, so we need field 3
          SALT=$(echo "$USER_HASH" | cut -d'$' -f3)
          
          if [[ -n "$SALT" ]]; then
            # Generate test hash with the same salt
            TEST_HASH=$(echo "changeme" | mkpasswd -s -m sha-512 -S "$SALT")
            
            if [[ "$TEST_HASH" == "$USER_HASH" ]]; then
              echo "Default password is active"
              touch "$FLAG_FILE"
            else
              echo "Password has been changed"
              rm -f "$FLAG_FILE" 2>/dev/null || true
            fi
          else
            echo "Could not extract salt from password hash"
          fi
        elif [[ "$USER_HASH" =~ ^\$y\$ ]]; then
          # yescrypt hash (whats most likely in use, im just too lazy to verify how nix does this)
          echo "Detected yescrypt hash"
          # For yescrypt, we need to extract the parameters and salt differently
          # Format: $y$params$salt$hash
          # just try to generate a hash and compare
          
          # Extract everything between $y$ and the last $ (params and salt)
          PARAMS_AND_SALT=$(echo "$USER_HASH" | sed 's/^\$y\$\(.*\)\$[^$]*$/\1/')
          
          if [[ -n "$PARAMS_AND_SALT" ]]; then
            # Generate test hash with yescrypt
            TEST_HASH=$(echo "changeme" | mkpasswd -s -m yescrypt -S "$PARAMS_AND_SALT")
            
            if [[ "$TEST_HASH" == "$USER_HASH" ]]; then
              echo "Default password is active"
              touch "$FLAG_FILE"
            else
              echo "Password has been changed"
              rm -f "$FLAG_FILE" 2>/dev/null || true
            fi
          else
            echo "Could not extract parameters from yescrypt hash"
          fi
        else
          echo "Password hash format not recognized (hash starts with: $(echo "$USER_HASH" | cut -c1-4))"
          echo "Unable to verify if default password is in use"
          rm -f "$FLAG_FILE" 2>/dev/null || true
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
  systemd.user.services.password-warning-notify = {
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