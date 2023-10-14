{ pkgs, ... }:
{
  systemd.user.services.rot8 = let
    # x12 only
    ID = "525C";
  in {
    Unit = {
      Description = "Automatic screen rotation";
    };
    Install = {
      WantedBy = [ "default.target" ];
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
            ${pkgs.xorg.xinput}/bin/xinput set-prop "Wacom HID 525C Finger" 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
            ${pkgs.xorg.xinput}/bin/xinput set-prop "Wacom HID 525C Pen" 'libinput Calibration Matrix' 0 -1 1 1 0 0 0 0 1
            ${pkgs.xorg.xrandr}/bin/xrandr -o left
          elif [ "$match" = "normal" ]
          then
            echo "back to normal"
            ${pkgs.xorg.xinput}/bin/xinput set-prop "Wacom HID 525C Finger"  'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1
            ${pkgs.xorg.xinput}/bin/xinput set-prop "Wacom HID 525C Pen"  'libinput Calibration Matrix' 1 0 0 0 1 0 0 0 1
            ${pkgs.xorg.xrandr}/bin/xrandr -o normal
          fi
        done
      ''}";
    };
  };
}
