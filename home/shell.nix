{ config, pkgs, my, ... }:

{
  # Bash configuration
  programs.bash = {
    enable = true;
    initExtra = ''
      export PATH="$HOME/.npm-global/bin:$PATH"
      
      # Kitty shell integration
      if [[ "$TERM" == "xterm-kitty" ]]; then
        # Create a custom sudo wrapper that changes background color
        sudo() {
          # Use dark red background for sudo commands
          printf "\033]11;#2D1B1B\007"
          command sudo "$@"
          local exit_code=$?
          printf "\033]11;#1A1B26\007"
          return $exit_code
        }
        
        # Make sure we start with the correct background
        printf "\033]11;#1A1B26\007"
      fi
    '';
    shellAliases = {
      # TPM2 enrollment/re-enrollment alias
      reseal = "sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/luks";
      
      # ModrinthApp with proper scaling
      ModrinthApp = "GDK_BACKEND=x11 ModrinthApp";
      modrinth-app = "GDK_BACKEND=x11 ModrinthApp";
      
      # NixOS rebuild commands
      nixos-sync = "sudo rsync -av --delete ~/nixos-dev/ /etc/nixos/ && (cd /etc/nixos && sudo git add .) && sudo nixos-rebuild switch --flake /etc/nixos";
      nrs = "nixos-sync"; # Short alias
      nixos-test = "sudo rsync -av --delete ~/nixos-dev/ /etc/nixos/ && (cd /etc/nixos && sudo git add .) && sudo nixos-rebuild test --flake /etc/nixos";
      nrt = "nixos-test"; # Short alias
      nixos-boot = "sudo rsync -av --delete ~/nixos-dev/ /etc/nixos/ && (cd /etc/nixos && sudo git add .) && sudo nixos-rebuild boot --flake /etc/nixos";
      nrb = "nixos-boot"; # Short alias
    };
  };
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = my.username;
    userEmail = my.userEmail;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Starship prompt
  programs.starship.enable = true;

  # NPM global packages
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    GDK_BACKEND = "x11";
  };
  home.file.".npm-global/.keep".text = "";
  home.sessionPath = [ "$HOME/.npm-global/bin" ];
}