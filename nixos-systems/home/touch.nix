{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.touch;

in {
  options.services.touch = {
    enable = mkEnableOption "touch";
  };

  config = mkIf cfg.enable {
    systemd.user.services.tsg = {
      Unit = {
        Description = "touch gestures via tsg";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Environment = ''RUST_LOG=debug'';
        ExecStart = "${pkgs.touchscreen-gestures}/bin/touchscreen-gestures";
      };
    };
  };

}
