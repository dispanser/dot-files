{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.touch;

in {
  meta.maintainers = [ hm.maintainers.GaetanLepage ];

  options.services.touch = {
    enable = mkEnableOption "touch";
    finger-device = mkOption {
      type = types.str;
      description = ''
        xinput device name for touch device (finger controls)
      '';
      example = "Wacom HID 525C Finger";
    };
    pen-device = mkOption {
      type = types.str;
      description = ''
        xinput device name for touch device (pen controls)
      '';
      example = "Wacom HID 525C Pen";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.lisgd = let
      ROT = "3";
      xdt = "${pkgs.xdotool}/bin/xdotool";
    in {
      Unit = {
        Description = "touch gestures via lisgd";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "touch.sh" ''
          DEV=$(${pkgs.xorg.xinput}/bin/xinput list-props '${cfg.finger-device}' | ${pkgs.ripgrep}/bin/rg 'Device Node' | ${pkgs.coreutils}/bin/cut -f 2 -d\")
          echo device path: $DEV
          ${pkgs.lisgd}/bin/lisgd -v \
          -d $DEV \
          -g "3,LR,N,S,R,${xdt} key alt+j" \
          -g "3,RL,N,S,R,${xdt} key alt+k" \
          -g "1,LR,L,S,R,${xdt} key ctrl+h" \
          -g "1,RL,R,S,R,${xdt} key ctrl+l" \
          -g "1,UD,T,S,R,${pkgs.psmisc}/bin/killall -r onboard" \
          -g "1,DU,B,S,R,${pkgs.onboard}/bin/onboard -l /home/pi/src/github/dispanser/dot-files/configs/onboard/mine.onboard &" \
          -g "2,UD,T,S,R,${pkgs.light}/bin/light -A 10" \
          -g "2,DU,B,S,R,${pkgs.light}/bin/light -U 10" \
          -o ${ROT}
        ''}";
      };
    };

    systemd.user.services.rot8 = {
      Unit = {
        Description = "Automatic screen rotation";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        # rot8 can't rotate the pen device, it requires a different matrix / attribute
        # rot8 --touchscreen "Wacom HID 525C Finger"  "Wacom HID 525C Pen"
        ExecStart = "${pkgs.writeShellScript "rotate.sh" ''
          ${pkgs.iio-sensor-proxy}/bin/monitor-sensor | while read -r orientation;
          do
            echo o: "$orientation"

            match=$(echo "$orientation" | ${pkgs.gnused}/bin/sed -E -e 's/.*((normal|left-up)).*/\1/g')
            export match
            if test -z "$match"
            then
              echo zero match: ... "$match" ...
              continue
            fi
            echo tp\; match is non-zero "$match"
            if [ "$match" = "left-up" ]
            then
              echo "rotating left"
              ${pkgs.xorg.xinput}/bin/xinput set-prop "${cfg.finger-device}" 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
              ${pkgs.xorg.xinput}/bin/xinput set-prop "${cfg.pen-device}" 'libinput Calibration Matrix' 0 -1 1 1 0 0 0 0 1
              ${pkgs.xorg.xrandr}/bin/xrandr -o left
            elif [ "$match" = "normal" ]
            then
              echo "back to normal"
              ${pkgs.xorg.xinput}/bin/xinput set-prop "${cfg.finger-device}"  'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1
              ${pkgs.xorg.xinput}/bin/xinput set-prop "${cfg.pen-device}"  'libinput Calibration Matrix' 1 0 0 0 1 0 0 0 1
              ${pkgs.xorg.xrandr}/bin/xrandr -o normal
            fi
          done
        ''}";
      };
    };
  };

}
