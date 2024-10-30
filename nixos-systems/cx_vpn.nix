{ lib, pkgs, ... }:

{
  programs.openvpn3.enable = true;
  services.openvpn.servers = {
    staging  = { 
      config = "config /home/pi/projects/coralogix/vpn/staging.opvn";
      extraArgs = [];
    };
  };
}

