{ config, pkgs, lib, ... }:

{
  # Set your time zone
  time.timeZone = config.my.timezone;

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  # System fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    redhat-official-fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}