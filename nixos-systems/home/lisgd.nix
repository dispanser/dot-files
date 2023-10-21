{ pkgs, ... }:
{
  systemd.user.services.lisgd = let
    ROT = "3";
    xdt = "${pkgs.xdotool}/bin/xdotool";
  in {
    Unit = {
      Description = "touch gestures via lisgd";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "touch.sh" ''
        DEV=$(${pkgs.xorg.xinput}/bin/xinput list-props 'Wacom HID 525C Finger' | ${pkgs.ripgrep}/bin/rg 'Device Node' | ${pkgs.coreutils}/bin/cut -f 2 -d\")
        echo device path: $DEV
        ${pkgs.lisgd}/bin/lisgd -v \
        -d $DEV \
        -g "3,LR,N,S,R,${xdt} key alt+j" \
        -g "3,RL,N,S,R,${xdt} key alt+k" \
        -g "1,LR,L,S,R,${xdt} key ctrl+h" \
        -g "1,RL,R,S,R,${xdt} key ctrl+l" \
        -g "1,UD,T,S,R,${pkgs.light}/bin/light -A 10" \
        -g "1,DU,B,S,R,${pkgs.light}/bin/light -U 10" \
        -g "2,UD,N,S,R,${pkgs.psmisc}/bin/killall -r onboard" \
        -g "2,DU,N,S,R,${pkgs.onboard}/bin/onboard -l /home/pi/src/github/dispanser/dot-files/configs/onboard/mine.onboard &" \
        -o ${ROT}
      ''}";
    };
  };
}
