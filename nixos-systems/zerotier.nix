{ config, pkgs, ... }:

# To add a system that's not visible from zerotier UI:
#  - `sudo zerotier-cli info`
#  - add the number from the output to the network in "Manually add member"
{
  services.zerotierone = {
	  enable = true;
	  joinNetworks = [ "0cccb752f752340e" ];
  };
}

