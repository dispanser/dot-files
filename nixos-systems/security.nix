{ pkgs, ... }:

{
  nix.settings.allowed-users = [ "@wheel" ];

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = true;

    extraRules = 
    # Absolute paths are required. Used to be ${pkgs.s-tui}, but that doesn't
    # match the actual path, comprised of just symlinks from a central place.
    let prefix = "/run/current-system/sw/bin";
    in [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${prefix}/systemctl restart zerotierone.service";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/s-tui";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/powertop";
            options = [ "SETENV" "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
