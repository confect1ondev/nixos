{ config, pkgs, lib, ... }:

{
  # System service to check TPM enrollment and create a flag file
  systemd.services.tpm-enrollment-check = {
    description = "Check TPM2 enrollment status for LUKS";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = with pkgs; [ 
      cryptsetup 
      coreutils 
      gnugrep 
    ];
    
    script = ''
      FLAG_FILE="/run/tpm-enrolled"
      LUKS_DEVICE="/dev/disk/by-partlabel/luks"
      
      # Check if LUKS device exists
      if [[ ! -e "$LUKS_DEVICE" ]]; then
        echo "LUKS device not found"
        exit 0
      fi
      
      # Check if already enrolled with TPM2
      if cryptsetup luksDump "$LUKS_DEVICE" 2>/dev/null | grep -q "systemd-tpm2"; then
        echo "TPM2 enrolled for LUKS"
        touch "$FLAG_FILE"
      else
        echo "TPM2 not enrolled"
        rm -f "$FLAG_FILE" 2>/dev/null || true
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  # User service to check the flag and notify
  systemd.user.services.tpm-enrollment-notify = {
    description = "Notify user if TPM2 enrollment is needed for LUKS";
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
      
      # Check if TPM device exists
      if [[ ! -e /dev/tpm0 ]] && [[ ! -e /dev/tpmrm0 ]]; then
        echo "No TPM device found, skipping enrollment check"
        exit 0
      fi
      
      # Check the flag file created by the system service
      if [[ -f /run/tpm-enrolled ]]; then
        echo "TPM2 already enrolled for LUKS (flag file exists)"
        exit 0
      fi
      
      # Send desktop notification
      notify-send -u critical -t 0 \
        "TPM2 Enrollment Available" \
        "Your disk encryption can be unlocked automatically using TPM2.\nRun 'reseal' in terminal to enable this feature."
      
      echo "TPM2 enrollment notification sent"
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}