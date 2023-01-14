{
	services.thinkfan = {
		enable = true;
		extraArgs = [ "-b" "0" ];

		sensors = [
			{
				type = "tpacpi";
				query = "/proc/acpi/ibm/thermal";
			}
		];
		fans = [
			{
				type = "tpacpi";
				query = "/proc/acpi/ibm/fan";
			}
		];
		levels = [
			[0 0  35]
			[1 10 75]
			[2 65 85]
			[3 66 86]
			[4 67 87]
			[5 68 88]
			[7 70 32767]
		];
	};

	# boot.extraModprobeConfig = ''
	# 	options thinkpad_acpi fan_control=1"
	# '';
}
