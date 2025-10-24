{ lib, ... }:

{
  options.my = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "confect1on";
      description = "Primary user account name";
    };
    
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "me@confect1on.com";
      description = "User email for git and other configurations";
    };
    
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Chicago";
      description = "System timezone";
    };
    
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };
      
      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard variant";
      };
    };
    
    ports = {
      starttree = lib.mkOption {
        type = lib.types.port;
        default = 8085;
        description = "Port for StartTree start page service";
      };
      
      moneroRpc = lib.mkOption {
        type = lib.types.port;
        default = 18081;
        description = "Port for Monero RPC service";
      };
    };
  };
}