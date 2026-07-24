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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher = {
      url = "github:JPyke3/hytale-launcher-nix";
    };
    witr = {
      url = "github:pranshuparmar/witr";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, firefox-addons, hytale-launcher, witr, claude-code-nix }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

    # Shared overlay for all hosts
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # Shared special args for all modules
    specialArgs = { inherit inputs; };

    # Helper to create a host configuration
    mkHost = hostDir: nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        { nixpkgs.overlays = [ overlay-unstable ]; }
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        ({ config, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Shared home base + per-host home.nix. Every host directory must
          # contain a home.nix (it may be empty: `{ }`).
          home-manager.users.${config.my.username} = {
            imports = [
              ./home
              (hostDir + "/home.nix")
            ];
          };
          home-manager.backupFileExtension = "bkp";
          home-manager.extraSpecialArgs = {
            inherit (config) my;
            inherit inputs firefox-addons;
          };
        })
        hostDir
      ];
    };
  in
  {
    packages.${system}.claude-monitor = pkgs.callPackage ./pkgs/claude-monitor.nix { };

    nixosConfigurations = {
      confect1on = mkHost ./hosts/confect1on;
      laptop = mkHost ./hosts/laptop;
    };
  };
}