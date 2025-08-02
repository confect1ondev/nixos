{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    
    # Font configuration
    font = {
      name = "Fira Code Regular";
      size = 13.0;
    };
    
    # Additional font settings
    settings = {
      # Font features and symbols
      bold_font = "Fira Code Retina";
      font_symbol = "Symbols Nerd Font Mono";
      font_features = "FiraCode-Regular +zero +ss01 +ss02 +ss03 +ss04 +ss05 +cv31";
      
      # Symbol mappings for proper icon rendering
      symbol_map = "U+1F000-U+1FAFF Symbols Nerd Font Mono";

      # Terminal behavior
      shell_integration = "enabled";
      cursor_shape = "block";
      cursor_blink_interval = 0;

      # Catppuccin Mocha color scheme
      # Background and foreground
      foreground = "#CDD6F4";
      background = "#1A1B26";
      selection_foreground = "#11111B";
      selection_background = "#F5E0DC";

      # URL styling
      url_color = "#F5E0DC";

      # Terminal colors (Catppuccin Mocha palette)
      color0 = "#45475A";   # black
      color1 = "#F38BA8";   # red
      color2 = "#A6E3A1";   # green
      color3 = "#F9E2AF";   # yellow
      color4 = "#89B4FA";   # blue
      color5 = "#F5C2E7";   # magenta
      color6 = "#94E2D5";   # cyan
      color7 = "#BAC2DE";   # white

      # Bright colors
      color8 = "#585B70";    # bright black
      color9 = "#F38BA8";    # bright red
      color10 = "#A6E3A1";   # bright green
      color11 = "#F9E2AF";   # bright yellow
      color12 = "#89B4FA";   # bright blue
      color13 = "#F5C2E7";   # bright magenta
      color14 = "#94E2D5";   # bright cyan
      color15 = "#A6ADC8";   # bright white

      # Additional styling
      window_padding_width = 8;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      
      # Performance and behavior
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Tab styling
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
    };
    
    # Extra configuration
    extraConfig = ''
      # Shell integration for prompt marking
      shell_integration enabled no-cursor
      
      # Mark colors for shell integration
      mark1_foreground black
      mark1_background #98d3cb
      mark2_foreground black
      mark2_background #f2dcd3
      mark3_foreground black
      mark3_background #f274bc
    '';
  };
}