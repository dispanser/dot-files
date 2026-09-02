This subdirectory contains the darwin-specific flake and nix configuration.
It links to `../home` for a shared home-manager setup, but does not share
a `flake.lock` with the NixOS hosts so we're able to upgrade at a different pace.
