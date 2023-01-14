{
  description = "System Configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/pi/src/github/dispanser/nixpkgs";
    # consistent, system-wide nix pkgs for user + system configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      x1t3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./x1t3.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pi = import ./home-conf.nix;
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
            home-manager.users.pi = import ./home-conf.nix;
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
            home-manager.users.pi = import ./home-conf.nix;
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
            home-manager.users.pi = import ./home-conf.nix;
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
            home-manager.users.pi = import ./home-conf.nix;
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
            home-manager.users.pi = import ./home-conf.nix;
          }
        ];
      };
    };
  };
}
