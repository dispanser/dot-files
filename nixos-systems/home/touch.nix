{ config, lib, pkgs, osConfig, ... }:

let
  isServer = osConfig.networking.hostName == "tiny";
  isKite = osConfig.networking.hostName == "kite";
in
{
  programs.touchscreen-gestures = lib.mkIf (!isServer && !isKite) {
    enable = true;
    package = pkgs.touchscreen-gestures;
    pollIntervalMs = 500;
    actions = [
      {
        gesture = [ "U,S,B" "U,S,B" ];
        cmd = "BothScreens";
      }
      {
        # brightnessctl set '10%-'
        gesture = [ "D,S" "D,S" "D,S" "D,S" ];
        run = "${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
      }
      {
        gesture = [ "U,S" "U,S" "U,S" "U,S" ];
        run = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      }
      {
        gesture = [ "D,L" "D,L" "D,L" "D,L" ];
        run = "${pkgs.brightnessctl}/bin/brightnessctl set 30%+";
      }
      {
        gesture = [ "U,L" "U,L" "U,L" "U,L" ];
        run = "${pkgs.brightnessctl}/bin/brightnessctl set 30%-";
      }
      {
        gesture = [ "R,S,L" "R,S,L" ];
        run = "${pkgs.niri}/bin/niri msg action focus-column-left";
      }
      {
        gesture = [ "L,S,R" "L,S,R" ];
        run = "${pkgs.niri}/bin/niri msg action focus-column-right";
      }
      {
        gesture = [ "U,S,B" "U,S,B" ];
        run = "${pkgs.niri}/bin/niri msg action focus-workspace-down";
      }
      {
        gesture = [ "D,S,T" "D,S,T" ];
        run = "${pkgs.niri}/bin/niri msg action focus-workspace-up";
      }
    ];
  };
}
