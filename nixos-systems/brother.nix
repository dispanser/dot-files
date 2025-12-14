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

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_3550CDW";
        location = "Home";
        deviceUri = "http://192.168.1.226/BINARY_P1";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_3550CDW";
  };

}

