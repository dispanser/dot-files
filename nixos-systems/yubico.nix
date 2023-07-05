{ config, pkgs, ... }:

{
  services.pcscd.enable = true;

  security.pam.yubico = {                                           
      enable = false;
      debug  = true;
      mode   = "challenge-response";
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

}
