# Home Manager module for nuru, the niri session helper (project terminals,
# project browser, spawn-or-focus). The overlay in ../overlays/nuru.nix builds
# the package from the private checkout; both platform flakes import this
# module into home-manager's sharedModules, and the shared home configuration
# enables it on Linux only.
#
# nuru is only useful inside a running niri session: it shells out to
# `niri msg`, so enabling it on other platforms (e.g. macOS) is a no-op.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nuru;
in
{
  options.programs.nuru = {
    enable = lib.mkEnableOption "nuru, the niri session helper";

    package = lib.mkPackageOption pkgs "nuru" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
