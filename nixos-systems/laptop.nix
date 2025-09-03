# generic configs for a laptop.
{ config, pkgs, ... }:

{
  programs.light.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

	services.tlp = {
		enable      = true;
		settings = {
			START_CHARGE_THRESH_BAT0    = 65;
			STOP_CHARGE_THRESH_BAT0     = 90;
			CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
			ENERGY_PERF_POLICY_ON_BAT   = "power";
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
