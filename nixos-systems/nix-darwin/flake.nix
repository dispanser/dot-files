{
  # this flake could easily be merged into ../flake.nix by merging inputs and
  # outputs, quite literally. We're currently using a separate flake so we can
  # `nix flake update` independently

  description = "My darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nix-darwin, home-manager, ...}@inputs:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#yukon
    darwinConfigurations."yukon" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."thomas.peiselt" = import ../home/home.nix;
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."yukon".pkgs;
  };
}
