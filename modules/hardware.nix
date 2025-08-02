{ config, pkgs, lib, ... }:

{
  # Enable all hardware firmware
  hardware.firmware = [ pkgs.linux-firmware ];

  # Common hardware support
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.ledger.enable = true;
}