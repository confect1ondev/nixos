{ config, pkgs, lib, firefox-addons, my, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        
        # Install extensions 
        extensions.packages = with firefox-addons.packages.${pkgs.system}; [
          new-tab-override
          ublock-origin
          darkreader
        ];
        
        # Set preferences
        settings = {
          # Homepage settings
          "browser.startup.homepage" = "http://localhost:${toString my.ports.starttree}/";
          "browser.startup.page" = 1;
          
          # Extension settings
          "extensions.autoDisableScopes" = 0;
          "extensions.enabledScopes" = 15;
          
          # Don't create desktop shortcuts
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          
          # Dark mode settings
          "ui.systemUsesDarkTheme" = 1;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "layout.css.prefers-color-scheme.content-override" = 0;
          "devtools.theme" = "dark";
          
          # Force dark mode
          "browser.in-content.dark-mode" = true;
          "ui.prefersReducedMotion" = 0;
          "widget.content.allow-gtk-dark-theme" = true;
          "widget.gtk.alt-theme.dark" = true;
          
          # Built-in Firefox dark theme
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          
          # Additional dark mode preferences
          "browser.display.background_color" = "#1c1b22";
          "browser.display.foreground_color" = "#fbfbfe";
        };
        
        # Bookmarks
        bookmarks = {
          force = true;
          settings = [
            {
              name = "NixOS";
              toolbar = true;
              bookmarks = [
                {
                  name = "NixOS Search";
                  url = "https://search.nixos.org/packages";
                }
                {
                  name = "Home Manager Options";
                  url = "https://nix-community.github.io/home-manager/options.xhtml";
                }
              ];
            }
          ];
        };
      };
    };
  };
}