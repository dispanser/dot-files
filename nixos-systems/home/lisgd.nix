{ pkgs, ... }:
{
  systemd.user.services.lisgd = let
    ROT = "1";
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
        ${pkgs.lisgd}/bin/lisgd -v \
        -d /dev/input/event23 \
        -g "3,LR,N,S,R,${xdt} key alt+j" \
        -g "3,RL,N,S,R,${xdt} key alt+k" \
        -g "1,LR,L,S,R,${xdt} key ctrl+h" \
        -g "1,RL,R,S,R,${xdt} key ctrl+l" \
        -g "1,UD,T,S,R,light -A 10" \
        -g "1,DU,B,S,R,light -U 10" \
        -o ${ROT}
      ''}";
    };
  };
}