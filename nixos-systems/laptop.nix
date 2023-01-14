# generic configs for a laptop.
{ config, pkgs, ... }:

{
  programs.light.enable = true;

	services.tlp = {
		enable      = true;
		settings = {
			START_CHARGE_THRESH_BAT0    = 75;
			STOP_CHARGE_THRESH_BAT0     = 95;
			CPU_SCALING_GOVERNOR_ON_BAT = "ondemand";
			ENERGY_PERF_POLICY_ON_BAT   = "ondemand";
		};
	};

	services.upower.enable = true;
	services.acpid = {
		enable = true;
	};

	services.redshift = {
		enable = true;
	};

	location = {
		latitude  = 51.0;
		longitude = 11.5;
	};
}
