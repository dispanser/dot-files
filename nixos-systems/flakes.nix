{ config, pkgs, ... }:

# see https://nixos.wiki/wiki/Flakes
# TODO: at one day, this won't be experimental anymore.
{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
