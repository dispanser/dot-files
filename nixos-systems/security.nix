{ ... }:

{
  nix.settings.allowed-users = [ "@wheel" ];

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = true;

    extraRules = 
    # Absolute paths are required. Used to be ${pkgs.s-tui}, but that doesn't
    # match the actual path, comprised of just symlinks from a central place.
    let prefix = "/run/current-system/sw/bin";
        home_prefix = "/etc/profiles/per-user/pi/bin/";
    in [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${prefix}/systemctl restart zerotierone.service";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/systemctl restart wpa_supplicant-wlan0.service";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/s-tui";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${home_prefix}/btop";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/powertop";
            options = [ "SETENV" "NOPASSWD" ];
          }
          {
            command = "${prefix}/bluetoothctl";
            options = [ "SETENV" "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
