{ pkgs, ... }:

{
  nix.settings.allowed-users = [ "@wheel" ];

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = true;

    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl restart zerotierone.service";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${pkgs.s-tui}/bin/s-tui";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${pkgs.powertop}/bin/powertop";
            options = [ "SETENV" "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
