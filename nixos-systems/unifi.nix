{ pkgs, ... }:

{
  services.unifi = {
	  enable = true;
	  initialJavaHeapSize = 256;
	  maximumJavaHeapSize = 256;
	  unifiPackage = pkgs.unifi;
  };
}
