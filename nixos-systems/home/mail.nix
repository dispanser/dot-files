{ config, pkgs, ... }:
{
  sops = {
    secrets."imap/kgo/pass" = { };
    secrets."imap/dispanser.de/pass" = { };
  };
  programs.offlineimap = {
    enable = true;
    pythonFile = ''
      from subprocess import check_output

      def get_pass(account):
          return check_output("pass " + account, shell=True).rstrip()
      def get_secret(secret):
          return check_output("cat " + secret, shell=True).rstrip()
    '';
  };

  accounts.email = {
    certificatesFile = "/etc/ssl/certs/ca-certificates.crt";
    maildirBasePath = ".mail";
    accounts.kgo = {
      primary = true;
      address = "pi@kulturguerilla.org";
      userName = "pi@kulturguerilla.org";
      realName = "Thomas Peiselt";

      passwordCommand = "cat ${config.sops.secrets."imap/kgo/pass".path}";
      mu.enable = true;
      neomutt.enable = true;

      imap = {
        host = "imap.purelymail.com";
        port = 993;
        tls = {
          enable = true;
          certificatesFile = "/etc/ssl/certs/ca-certificates.crt";
          useStartTls = true;
        };
      };

      msmtp = {
        enable = true;
        extraConfig.passwordeval = "cat ${config.sops.secrets."imap/kgo/pass".path}";
      };

      smtp = {
        host = "smtp.purelymail.com";
        port = 587;
        tls = {
          useStartTls = true;
        };
      };

      offlineimap = {
        enable = true;
        postSyncHookCommand = ''${pkgs.bash}/bin/bash -c "MAILDIR=~/.mail/kgo ${pkgs.mu}/bin/mu index"'';
        extraConfig = {
          account = {
            quick = 10;
            autorefresh = 10;
          };
          remote = {
            remotepasseval = ''get_secret("${config.sops.secrets."imap/kgo/pass".path}")'';
            maxconnections = 5;
            remoteport = 993;
            keepalive = 90;
            holdconnectionopen = "yes";
          };
        };
      };
    };

    accounts."dispanser.de" = {
      primary = false;
      address = "me@dispanser.de";
      userName = "me@dispanser.de";
      realName = "Thomas Peiselt";

      imap = {
        host = "imap.purelymail.com";
        port = 993;
        tls = {
          enable = true;
          certificatesFile = "/etc/ssl/certs/ca-certificates.crt";
          useStartTls = true;
        };
      };

      msmtp = {
        enable = true;
        extraConfig.passwordeval = "cat ${config.sops.secrets."imap/dispanser.de/pass".path}";
      };

      smtp = {
        host = "smtp.purelymail.com";
        port = 587;
        tls = {
          useStartTls = true;
        };
      };


      offlineimap = {
        enable = true;
        postSyncHookCommand = ''${pkgs.bash}/bin/bash -c "MAILDIR=~/.mail/dispanser.de ${pkgs.mu}/bin/mu index"'';
        extraConfig = {
          account = {
            quick = 10;
            autorefresh = 60;
          };
          remote = {
            # remotepasseval = ''get_pass("personal/mail/purelymail.com/inbox.purelymail.com/me@dispanser.de")'';
            remotepasseval = ''get_secret("${config.sops.secrets."imap/dispanser.de/pass".path}")'';
            maxconnections = 5;
            remoteport = 993;
            keepalive = 90;
            holdconnectionopen = "yes";
          };
        };
      };
    };
  };
}
