{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.inputplug;
  script = "${pkgs.writeShellScript "inputplug.sh" ''
    ${pkgs.coreutils}/bin/echo calling bla with $1 / $2 / $3 / $4 >> /tmp/tyx/inplut_plug
    case $1_$3 in
      XIDeviceEnabled_XISlaveKeyboard*)
      ${pkgs.coreutils}/bin/echo detected keyboard connect, fixing keymap >> /tmp/tyx/inplut_plug
      ${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout us -option -option caps:escape -option compose:lwin-altgr -option lv3:ralt_switch
      ;;
    esac
  ''}";

in {
  options.services.inputplug = {
    enable = mkEnableOption "inputplug";
  };

  config = mkIf cfg.enable {

    systemd.user.services.inputplug = {

      Unit = {
        Description = "apply xkb settings to keyboards on connect";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
        # PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.inputplug}/bin/inputplug -d -c ${script}";
      };
    };
  };
}
