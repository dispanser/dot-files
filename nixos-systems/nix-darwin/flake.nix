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
    llm-agents.url = "github:numtide/llm-agents.nix";
    cx-cli.url = "github:coralogix/cx-cli";
    # nuru is a private checkout without a git remote. `git+file` reads the
    # committed tree into the store before evaluation, so the build stays pure.
    # Commit changes in the checkout and run `nix flake update nuru` to pick
    # them up.
    nuru = {
      url = "git+file:///Users/thomas.peiselt/projects/coralogix/src/nuru";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#ord
      darwinConfigurations."ord" = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              (import ../overlays/llama-benchy.nix)
              (import ../overlays/betterbench.nix)
              (import ../overlays/pyqt6-moc-qt612.nix)
              ((import ../overlays/nuru.nix) { nuru = inputs.nuru; })
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."thomas.peiselt" = import ../home/home.nix;
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
                ../modules/nuru.nix
              ];
              extraSpecialArgs = {
                isLinux = false;
                inputs = inputs;
              };
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."ord".pkgs;
    };
}
