{ pkgs, ... }:

let id_remarkable = "/home/pi/.ssh/remarkable";
    id_yubi =  "/home/pi/.ssh/yubikey_c.pub";
    id_feitian_solo = "/home/pi/.ssh/id_feitian_solo_ecdsa_sk";
    id_feitian_chain = "/home/pi/.ssh/id_feitian_chain_ecdsa_sk";
    id_ecdsa_pass = "/home/pi/.ssh/id_ecdsa";
    id_keys = [ id_yubi id_feitian_solo id_feitian_chain id_ecdsa_pass ];
in {
  programs.ssh = {
    enable = true;
    compression = true;
    forwardAgent = true;
    matchBlocks = {

      # remarkable - ebook reader with ssh
      "rm" = {
        hostname     = "192.168.1.31";
        user         = "root";
        identityFile = "/home/pi/.ssh/remarkable";
        extraOptions = {
          "HostkeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
        };
      };

      # remarkable direct: usb-c connection with `sudo dhcpcd ...`
      "rmd" = {
        hostname = "10.11.99.1";
        user = "root";
        identityFile = "~/.ssh/remarkable";
        extraOptions = {
          "HostkeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
        };
      };

      "tiny" = {
        hostname = "10.1.3.10";
        user = "pi";
        port = 65423;
        identityFile = id_keys;
      };

      "github.com" = {
        hostname = "github.com";
        user     = "git";
        identityFile = id_keys;
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

