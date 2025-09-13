{ pkgs, ... }:

let 
  home = if pkgs.stdenv.isDarwin
    then "/Users/thomas.peiselt/.ssh"
    else "/home/pi/.ssh";
  id_remarkable = "${home}/remarkable";
  id_yubi =  "${home}/yubikey_c.pub";
  id_feitian_solo = "${home}/id_feitian_solo_ecdsa_sk";
  id_feitian_chain = "${home}/id_feitian_chain_ecdsa_sk";
  id_ecdsa_pass = "${home}/id_ecdsa";
  cl_ed = "${home}/coralogix-github";
  unison_tiny = "${home}/unison_tiny";
  id_keys = [ id_yubi id_feitian_solo id_feitian_chain id_ecdsa_pass ];
in {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        compression = true;
        forwardAgent = true;
        controlMaster = "yes";
      };

      # remarkable - ebook reader with ssh
      "rm" = {
        hostname     = "192.168.1.31";
        user         = "root";
        identityFile = id_remarkable;
        extraOptions = {
          "HostkeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
        };
      };

      # remarkable direct: usb-c connection with `sudo dhcpcd ...`
      "rmd" = {
        hostname = "10.11.99.1";
        user = "root";
        identityFile = id_remarkable;
        extraOptions = {
          "HostkeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
        };
      };

      "tiny" = {
        hostname = "10.1.3.10";
        user = "pi";
        port = 65423;
        identityFile = unison_tiny;
        extraOptions = {
          IdentitiesOnly = "yes";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user     = "git";
        identityFile = [ cl_ed ] ++ id_keys;
      };

      "x1t3" = {
        hostname = "10.1.3.3";
        user = "pi";
        port = 65423;
        identityFile = id_keys;
      };
    };
  };
}

