# heavily inspired by https://github.com/jonhoo/configs/blob/c26f47c38310e02afb7e2acb7fd7ec5d75b84a1e/nix/modules/home/dev.nix
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
      url = "github:dispanser/touchscreen-gestures";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      overlays = (import ./overlays { tsg = inputs.tsg; });
      hosts = [ "tiny" "kite" "oxide" "x12" "chatham" ];
      system = "x86_64-linux";
    in
    {
      overlays.default = overlays;
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (
        name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            llm-agents = inputs.llm-agents.packages.${system};
          };
          modules = [
            ./${name}.nix
            inputs.noctalia.nixosModules.default
            overlays
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.pi = import ./home/home.nix;
                sharedModules = [
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.tsg.homeManagerModules.default
                ];
                extraSpecialArgs = {
                  llm-agents = inputs.llm-agents.packages.${system};
                };
              };
            }
          ];
        }
      );
    };
}
