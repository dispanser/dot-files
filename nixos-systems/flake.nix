{
  description = "System Configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tsg = {
      url = "path:/home/pi/src/github/dispanser/touchscreen-gestures";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, tsg, ... }@inputs: 
  let
      home_manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.pi = import ./home/home.nix;
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];
      };
      overlays = (import ./overlays { inherit tsg; } );
  in {
    overlays.default = overlays;
    nixosConfigurations = {
      x1t3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./x1t3.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      # Tragbar
      chatham = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./chatham.nix
          overlays
          home-manager.nixosModules.home-manager
          {
            home-manager = home_manager;
          }
        ];
      };
      # Desk Mini
      tiny = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./tiny.nix
          overlays
          home-manager.nixosModules.home-manager
          {
            home-manager = home_manager;
          }
        ];
      };
      # X12 Gen 2
      oxide = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./oxide.nix
          overlays
          home-manager.nixosModules.home-manager {
            home-manager = home_manager;
          }
        ];
      };
      x12 = nixpkgs.lib.nixosSystem {
        # inherit pkgs;
        system = "x86_64-linux";
        modules = [
          ./x12.nix
          overlays
          home-manager.nixosModules.home-manager {
            home-manager = home_manager;
          }
        ];
      };
      # Big Boy
      kite = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # specialArgs = {inherit inputs outputs;};
        modules = [
          ./kite.nix
          overlays
          home-manager.nixosModules.home-manager
          {
            home-manager = home_manager;
          }
        ];
      };
      # Legion Go
      voyager = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./voyager.nix
          overlays
          home-manager.nixosModules.home-manager {
            home-manager = home_manager;
          }
        ];
      };
    };
    homeConfigurations.pi = {
      # defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./home.nix ];
    };
  };
}
