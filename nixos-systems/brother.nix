{ config, pkgs, ... }:

{
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = { brother = { ip = "192.168.1.43"; model = "DCP-L3550CDW"; }; };
    };
  };

  services.printing = {
    enable  = true;
    drivers = with pkgs; [ gutenprint brlaser ] ;
  };
}

