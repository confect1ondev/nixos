{ config, pkgs, lib, ... }:

{
  # TPM2 enrollment notification service  
  systemd.user.services.tpm-enrollment-notify = {
    description = "Notify user if TPM2 enrollment is needed for LUKS";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    
    path = with pkgs; [ 
      cryptsetup 
      coreutils 
      gnugrep 
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
      
      # Check if LUKS device exists
      LUKS_DEVICE="/dev/disk/by-partlabel/luks"
      if [[ ! -e "$LUKS_DEVICE" ]]; then
        echo "LUKS device not found, skipping enrollment check"
        exit 0
      fi
      
      # Check if already enrolled with TPM2
      if sudo cryptsetup luksDump "$LUKS_DEVICE" 2>/dev/null | grep -q "systemd-tpm2"; then
        echo "TPM2 already enrolled for LUKS"
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