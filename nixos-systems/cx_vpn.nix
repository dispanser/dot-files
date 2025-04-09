{ lib, pkgs, ... }:

{
  programs.openvpn3.enable = true;
  services.openvpn.servers = {
    stg  = { 
      config = "config /home/pi/projects/coralogix/vpn/stg1.opvn";
      autoStart = false;
    };
    production  = {
      config = "config /home/pi/projects/coralogix/vpn/production.ovpn";
      autoStart = false;
    };
  };
}

