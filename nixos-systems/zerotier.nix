{ config, pkgs, ... }:

{
  services.zerotierone = {
	  enable = true;
	  joinNetworks = [ "0cccb752f752340e" ];
  };
}

