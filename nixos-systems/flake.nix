{
  description = "System Configurations";

  # nixos-hardware.url = "github:nixos/nixos-hardware";
  # inputs.nixos-hardware.nixosModules.framework-12th-gen-intel

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      yukon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./yukon.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      x1t3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./x1t3.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      chatham = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./chatham.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = false;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      stoic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./stoic.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = false;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      tiny = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./tiny.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = false;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      epiphany = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./epiphany.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = false;
            };
            home-manager.users.pi = (import ./home/home.nix);
          }
        ];
      };
      x12 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./x12.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      ryzera = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./ryzera.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      epiphanix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./epiphanix.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      konsole = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./konsole.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
          }
        ];
      };
      voyager = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./voyager.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hasTouchScreen = true;
            };
            home-manager.users.pi = import ./home/home.nix;
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
