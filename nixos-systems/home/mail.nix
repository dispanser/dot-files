{ config, lib, pkgs, ... }:
{
  programs.offlineimap = {
    enable = true;
    pythonFile = ''
      from subprocess import check_output

      def get_pass(account):
          return check_output("pass " + account, shell=True).rstrip()
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

      neomutt = {
        enable = true;
      };

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
        extraConfig.passwordeval = "pass personal/mail/purelymail.com/pi@kulturguerilla.org/imap";
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
            autorefresh = 1;
          };
          remote = {
            remotepasseval = ''get_pass("personal/mail/purelymail.com/pi@kulturguerilla.org/imap")'';
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

      offlineimap = {
        enable = true;
        postSyncHookCommand = ''${pkgs.bash}/bin/bash -c "MAILDIR=~/.mail/kgo ${pkgs.mu}/bin/mu index"'';
        extraConfig = {
          account = {
            quick = 10;
            autorefresh = 1;
          };
          remote = {
            remotepasseval = ''get_pass("personal/mail/purelymail.com/inbox.purelymail.com/me@dispanser.de")'';
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
