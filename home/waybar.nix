{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        margin-top = 4;
        margin-left = 12;
        margin-right = 12;
        
        modules-left = [ "custom/power" "clock" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "custom/wallpaper" "custom/system" "pulseaudio" "bluetooth" "network" ];

        # Power button
        "custom/power" = {
          format = "⏻";
          tooltip = false;
          on-click = "systemctl poweroff";
          on-click-right = "systemctl reboot";
        };

        # Wallpaper button
        "custom/wallpaper" = {
          format = "";
          tooltip = true;
          tooltip-format = "Change Wallpaper";
          on-click = "${pkgs.waypaper}/bin/waypaper";
        };

        # Clock
        clock = {
          interval = 60;
          format = "{:%I:%M %p}";
          format-alt = "  {:%a, %b %d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          today-format = "<b>{}</b>";
        };

        # Workspaces
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{id}";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        # Combined system stats
        "custom/system" = {
          exec = pkgs.writeShellScript "waybar-system" ''
            cpu=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%d%%", ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat; sleep 0.2; grep 'cpu ' /proc/stat))
            mem=$(free -h | awk 'NR==2{printf "%s", $3}')
            disk=$(df -h / | awk 'NR==2{printf "%s", $5}')
            printf "  %s    %s    %s" "$cpu" "$mem" "$disk"
          '';
          interval = 2;
          on-click = "kitty -e btop";
          tooltip = true;
          tooltip-format = "System Resources";
          return-type = "raw";
        };

        # Audio
        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-bluetooth-muted = "󰝟";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        # Bluetooth
        bluetooth = {
          format = "";
          format-disabled = "";
          format-connected = " {num_connections}";
          format-connected-battery = " {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "dbus-launch blueman-manager";
        };

        # Network
        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "";
          format-linked = "";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}";
          tooltip-format-ethernet = "{ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };

      };
    };

    style = ''
      /* Catppuccin Mocha Colors */
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;
      @define-color text #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color subtext1 #bac2de;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;
      @define-color overlay0 #6c7086;
      @define-color overlay1 #7f849c;
      @define-color overlay2 #9399b2;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color sapphire #74c7ec;
      @define-color sky #89dceb;
      @define-color teal #94e2d5;
      @define-color green #a6e3a1;
      @define-color yellow #f9e2af;
      @define-color peach #fab387;
      @define-color maroon #eba0ac;
      @define-color red #f38ba8;
      @define-color mauve #cba6f7;
      @define-color pink #f5c2e7;
      @define-color flamingo #f2cdcd;
      @define-color rosewater #f5e0dc;

      /* Global styles */
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
        font-size: 14px;
        font-weight: 600;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      /* Main bar */
      window#waybar {
        background: transparent;
        color: @text;
      }

      /* Tooltips */
      tooltip {
        background: rgba(30, 30, 46, 0.95);
        border: 1px solid @surface1;
        border-radius: 12px;
        color: @text;
        padding: 8px;
      }

      tooltip label {
        color: @text;
      }

      /* General module styling */
      #clock,
      #custom-system,
      #pulseaudio,
      #bluetooth,
      #network,
      #custom-power,
      #custom-wallpaper {
        background: rgba(49, 50, 68, 0.85);
        color: @text;
        padding: 0 10px;
        margin: 0 2px;
        border-radius: 12px;
        border: 1px solid rgba(69, 71, 90, 0.8);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        /* backdrop-filter: blur(10px); */ /* Not supported in GTK */
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
      }

      /* Hover effects */
      #clock:hover,
      #custom-system:hover,
      #pulseaudio:hover,
      #bluetooth:hover,
      #network:hover,
      #custom-power:hover,
      #custom-wallpaper:hover {
        background: rgba(69, 71, 90, 0.9);
        border-color: @blue;
        box-shadow: 0 4px 16px rgba(137, 180, 250, 0.2);
        /* transform: translateY(-1px); */
      }

      /* Power button - perfect square */
      #custom-power {
        color: @red;
        font-size: 16px;
        min-width: 30px;
        min-height: 30px;
        padding: 3px 9px 3px 7px;
      }

      #custom-power:hover {
        background: rgba(243, 139, 168, 0.2);
        border-color: @red;
        box-shadow: 0 4px 16px rgba(243, 139, 168, 0.3);
      }

      /* Clock */
      #clock {
        color: @blue;
        font-weight: 700;
      }

      /* Workspaces */
      #workspaces {
        background: rgba(49, 50, 68, 0.85);
        border-radius: 12px;
        padding: 2px 6px;
        border: 1px solid rgba(69, 71, 90, 0.8);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        /* backdrop-filter: blur(10px); */ /* Not supported in GTK */
      }

      #workspaces button {
        background: transparent;
        color: @overlay2;
        border-radius: 6px;
        margin: 1px 2px;
        padding: 2px 6px;
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        font-weight: 600;
        font-size: 15px;
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.2);
        color: @blue;
        /* transform: scale(1.05); */
      }

      #workspaces button.active {
        background: linear-gradient(135deg, @blue, @sapphire);
        color: @base;
        box-shadow: 0 2px 8px rgba(137, 180, 250, 0.4);
        /* transform: scale(1.1); */
      }

      #workspaces button.urgent {
        background: @red;
        color: @base;
        /* animation: urgent-pulse 2s infinite; */
      }

      /* Urgent pulse animation */

      /* System stats */
      #custom-system {
        color: @green;
        font-size: 15px;
      }

      /* Audio */
      #pulseaudio {
        color: @mauve;
      }

      #pulseaudio.muted {
        color: @overlay1;
        background: rgba(108, 112, 134, 0.1);
      }

      /* Bluetooth */
      #bluetooth {
        color: @sapphire;
      }

      #bluetooth.disabled {
        color: @overlay1;
        background: rgba(108, 112, 134, 0.1);
      }

      #bluetooth.connected {
        color: @teal;
      }

      /* Network */
      #network {
        color: @sky;
      }

      #network.disconnected {
        color: @overlay1;
        background: rgba(108, 112, 134, 0.1);
      }

      #network.ethernet {
        color: @green;
      }

      /* Wallpaper button - perfect square like power button */
      #custom-wallpaper {
        color: @mauve;
        font-size: 16px;
        min-width: 30px;
        min-height: 30px;
        padding: 3px 9px 3px 7px;
      }

      #custom-wallpaper:hover {
        background: rgba(203, 166, 247, 0.2);
        border-color: @mauve;
        box-shadow: 0 4px 16px rgba(203, 166, 247, 0.3);
      }
    '';
  };
}