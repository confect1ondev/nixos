{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, agenix, firefox-addons }@inputs: 
  let
    system = "x86_64-linux";
    
    # Shared overlay for all hosts
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
    
    # Shared special args for all modules
    specialArgs = { inherit inputs; };
  in
  {
    nixosConfigurations = {
      confect1on = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        
        modules = [
          { nixpkgs.overlays = [ overlay-unstable ]; }
          disko.nixosModules.disko
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ config, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${config.my.username} = import ./home;
            home-manager.backupFileExtension = "bkp";
            home-manager.extraSpecialArgs = { 
              inherit (config) my;
              inherit inputs firefox-addons;
              hostName = config.networking.hostName;
            };
          })
          ./hosts/confect1on
        ];
      };
      
      laptop = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        
        modules = [
          { nixpkgs.overlays = [ overlay-unstable ]; }
          disko.nixosModules.disko
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ config, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${config.my.username} = import ./home;
            home-manager.backupFileExtension = "bkp";
            home-manager.extraSpecialArgs = { 
              inherit (config) my;
              inherit inputs firefox-addons;
              hostName = config.networking.hostName;
            };
          })
          ./hosts/laptop
        ];
      };
    };
  };
}