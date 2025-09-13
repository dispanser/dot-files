{ pkgs, ... }:

{
	# manually changed port to 18080 in /var/lib/unifi/data/system.properties
	# unifi.http.port
	# server name: townhall
  services.unifi = {
	  enable = true;
		openFirewall = true;
	  initialJavaHeapSize = 256;
	  maximumJavaHeapSize = 256;
	  unifiPackage = pkgs.unifi;
		mongodbPackage = pkgs.mongodb-7_0;
  };
}
