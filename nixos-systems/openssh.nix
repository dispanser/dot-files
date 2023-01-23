{ config, pkgs, ... }:

{
  services.openssh = {
	  enable                 = true;
	  settings.passwordAuthentication = false;
	  startWhenNeeded        = false;
	  listenAddresses        = [
	    { addr = "0.0.0.0"; port = 65423; } 
    ];
  };
}

