{ config, pkgs, my, lib, hostName, ... }:

{
  # Hyprpaper configuration
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/.config/hypr/wallpaper.png" ];
      wallpaper = [ ",~/.config/hypr/wallpaper.png" ];
      splash = false;
    };
  };
  
  # Hyprlock configuration
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = true;
        no_fade_out = true;
        hide_cursor = false;
        grace = 0;
        disable_loading_bar = true;
      };
      
      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          contrast = 1.2;
          brightness = 0.4;
          vibrancy = 0.3;
          vibrancy_darkness = 0.3;
          color = "rgba(240, 0, 0, 0.53)";
        }
      ];
      
      fade = {
        duration = 100;
      };
      
      input = {
        hide_cursor = false;
        disable_ctrlaltdel = true;
      };
      
      input-field = [
        {
          monitor = "";
          size = "320, 90";
          outline_thickness = 0;
          outer_color = "rgba(255, 0, 0, 1)";
          inner_color = "rgba(255, 0, 0, 1)";
          font_color = "rgb(0, 0, 0)";
          fade_on_empty = false;
          rounding = 0;
          check_color = "rgb(255, 0, 0)";
          placeholder_text = " TRM LOCKED";
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
      
      label = [
        # Top left labels - multilingual lock messages
        {
          monitor = "DP-1";
          text = "TERMINAL LOCKED – AUTHENTICATION REQUIRED";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -1%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "端末ロック中 – 認証が必要です";
          font_family = "Noto Sans CJK JP";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -3%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "ACCÈS RESTREINT – VEUILLEZ VOUS IDENTIFIER";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -5%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "ЗАЩИЩЕННЫЙ ТЕРМИНАЛ – ПОДТВЕРДИТЕ ДОСТУП";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -7%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "터미널 잠김 – 인증 필요";
          font_family = "Noto Sans CJK KR";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -9%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "BLOQUEO DE TERMINAL – AUTENTICACIÓN REQUERIDA";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -11%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "GERÄT GESPERRT – AUTHENTIFIZIERUNG ERFORDERLICH";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -13%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "BLOCCO TERMINALE – AUTENTICAZIONE RICHIESTA";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -15%";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "TERMINAL BLOQUEADO – AUTENTICAÇÃO NECESSÁRIA";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, -17%";
          halign = "left";
          valign = "top";
        }
        
        # Top right time/date/system labels
        {
          monitor = "DP-1";
          text = "cmd[update:40] echo \"DATE: $(date +%s.%3N)\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -1%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:40] echo \"$(date '+%I:%M:%S %p')\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -3%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:60000] echo \"$(date '+%B %d, %Y')\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -5%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:40] echo \"UPTIME: $(awk '{print int($1 * 1000)}' /proc/uptime)\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -9%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:100] awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%d days, %d hours, %d minutes\", d, h, m; else if(h>0) printf \"%d hours, %d minutes\", h, m; else printf \"%d minutes\", m}' /proc/uptime";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -11%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:100] echo \"PROC: $(ps -e | wc -l)\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -15%";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:100] df -h / | awk 'NR==2 { print \"DISK: \" $5 }'";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "-1%, -17%";
          halign = "right";
          valign = "top";
        }
        
        # Bottom left system info
        {
          monitor = "DP-1";
          text = "cmd[update:10000] echo \"OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 13%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:60000] echo \"KERNEL: $(uname -r)\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 11%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:1000] echo \"USER: $USER\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 9%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:1000] echo \"TTY: $(tty)\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 7%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:1000] echo \"SHELL: $SHELL\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 5%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:1000] bash -c '[[ -f /tmp/hyprlock-start ]] && journalctl --since \"$(cat /tmp/hyprlock-start)\" | grep \"password check failed\" | wc -l | xargs echo \"FAILED LOGINS:\" || echo \"FAILED LOGINS: N/A\"'";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 3%";
          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "DP-1";
          text = "cmd[update:1000] echo \"$(lsblk -o TYPE | grep crypt >/dev/null && echo 'ENCRYPTED (LUKS)' || echo 'NOT ENCRYPTED')\"";
          font_family = "Red Hat Mono";
          font_size = 18;
          color = "rgb(255, 0, 0)";
          position = "1%, 1%";
          halign = "left";
          valign = "bottom";
        }
      ];
    };
  };
  
  wayland.windowManager.hyprland = {
    enable = true;
    
    plugins = lib.optionals (hostName == "laptop") [
      pkgs.hyprlandPlugins.hyprgrass
    ];
    
    settings = {
      # Monitor configuration
      monitor = if hostName == "laptop" then [
        "eDP-1,1920x1080@60,0x0,1"
      ] else [
        "DP-1,3440x1440@165.00101,0x0,1"
        "HDMI-A-1,2560x1440@60,-1440x-650,1,transform,1"
      ];
      
      # Workspace assignments
      workspace = if hostName == "laptop" then [
        "1, monitor:eDP-1"
        "2, monitor:eDP-1"
        "3, monitor:eDP-1"
        "4, monitor:eDP-1"
        "5, monitor:eDP-1"
        "6, monitor:eDP-1"
        "7, monitor:eDP-1"
        "8, monitor:eDP-1"
        "9, monitor:eDP-1"
        "10, monitor:eDP-1"
      ] else [
        "1, monitor:HDMI-A-1"
        "2, monitor:DP-1"
      ];
      
      # Execute at launch
      exec-once = [
        "lock-script"
        "hyprpaper & mako"
        "wl-clipboard-history -t & wl-paste --watch cliphist store & rm \"$HOME/.cache/cliphist/db\""
        "hyprctl setcursor GoogleDot-Blue 24"
      ];
      
      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
      ];
      
      # Variables
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$appMenu" = "app-menu";
      
      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = if hostName == "laptop" then 0.2 else -1;
        kb_options = "caps:backspace";
      };
      
      general = {
        gaps_in = 2;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(3390ffFF) rgba(0066ffFF) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };
      
      decoration = {
        rounding = 10;
        
        blur = {
          enabled = true;
          size = 2;
          passes = 3;
          noise = 0;
          ignore_opacity = false;
          new_optimizations = true;
        };
        
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        
        dim_inactive = true;
        dim_strength = 0.1;
      };
      
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };
      
      master = {
        new_status = "master";
      };
      
      gestures = {
        workspace_swipe = true;
        workspace_swipe_cancel_ratio = 0.15;
      };
      
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
      
      # Hyprgrass plugin configuration (only applies on laptop)
      plugin = lib.mkIf (hostName == "laptop") {
        touch_gestures = {
          sensitivity = 4.0;  # Higher for tablet screens
          workspace_swipe_fingers = 3;
          long_press_delay = 400;
          resize_on_border_long_press = true;
          edge_margin = 10;
        };
      };
      
      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "opacity 0.94 0.94,class:^(Code|Spotify)$"
      ] ++ lib.optionals (hostName == "laptop") [
        # Virtual keyboard rules
        "float, class:^(wvkbd-mobintl)$"
        "size 100% 300, class:^(wvkbd-mobintl)$"
        "move 0 100%-300, class:^(wvkbd-mobintl)$"
        "animation slide, class:^(wvkbd-mobintl)$"
        "noblur, class:^(wvkbd-mobintl)$"
        "nofocus, class:^(wvkbd-mobintl)$"
      ];
      
      # Keybindings
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, SPACE, exec, $appMenu"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, F, exec, firefox"
        "$mainMod, R, exec, hyprctl dispatch resizeactive exact 1920 1080"
        "$mainMod, W, exec, wallpaper-switcher"
        
        # Lock and screenshots
        "SUPER, L, exec, lock-script"
        "SUPER, Z, exec, grim -g \"$(slurp)\""
        "SUPER SHIFT, Z, exec, grim -g \"0,0 3440x1440\""
        "SUPER ALT, Z, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SUPER ALT SHIFT, Z, exec, grim -g \"0,0 3440x1440\" - | wl-copy"
        
        # App shortcuts
        "ALT, 1, exec, brave"
        "ALT, 2, exec, firefox"
        "ALT, 3, exec, code"
        
        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        
        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        
        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        
        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        
        # Sound control
        ", code:121, exec, pamixer --toggle-mute"
        ", code:198, exec, pamixer --default-source -t"
        
        # Media control
        ", code:172, exec, playerctl play-pause"
        ", code:173, exec, playerctl previous"
        ", code:171, exec, playerctl next"
      ] ++ lib.optionals (hostName == "laptop") [
        # Hyprgrass edge swipes
        ", edge:r:l, workspace, +1"  # Swipe left from right edge - next workspace
        ", edge:l:r, workspace, -1"  # Swipe right from left edge - previous workspace
        ", edge:d:u, exec, pkill wvkbd-mobintl || wvkbd-mobintl -L 300"  # Swipe up from bottom - toggle keyboard
        ", edge:l:u, exec, pamixer -ui 5"  # Swipe up from left edge - volume up
        ", edge:l:d, exec, pamixer -ud 5"  # Swipe down from left edge - volume down
        
        # Hyprgrass finger gestures
        ", swipe:4:d, killactive"  # 4 finger swipe down - close window
        ", swipe:4:u, fullscreen, 0"  # 4 finger swipe up - toggle fullscreen
        ", tap:3, exec, app-launcher"  # 3 finger tap - app launcher
      ];
      
      binde = [
        ", code:122, exec, pamixer -ud 5"
        ", code:123, exec, pamixer -ui 5"
      ];
      
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ] ++ lib.optionals (hostName == "laptop") [
        # Hyprgrass long press gestures
        ", longpress:2, movewindow"  # 2 finger long press - move window
        ", longpress:3, resizewindow"  # 3 finger long press - resize window
      ];
    };
  };
}