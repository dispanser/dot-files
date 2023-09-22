{ config, lib, pkgs,... }:

{
  imports = [
    ./desktop.nix
    ./laptop.nix
    ./zerotier.nix
    ./security.nix
    ./flakes.nix
    ./adguard_dns.nix
	  ./brother.nix
    ./yubico.nix
  ];

  services.undervolt = {
    temp = 90;
    enable = false;
    useTimer = true;
    uncoreOffset = -50;
    gpuOffset = -45;
    coreOffset = -75;
    analogioOffset = -50;
    p1 = {
      limit = 65;
      window = 300;
    };
    p2 = {
      limit = 90;
      window = 224;
    };
  };

  virtualisation.docker.enable = true;

  services.espanso.enable = true;
  services.atd.enable   = true;
  services.fwupd.enable = true;
  security.pam.u2f.enable = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.firmware = with pkgs; [ 
    wireless-regdb 
  ];

  services.cron = {
	  enable         = true;
	  systemCronJobs = [
	      "17 10,21 * * * pi /home/pi/bin/backup-home.sh local"
	      "17 12 * * * pi /home/pi/bin/backup-home.sh backblaze"
        "17 11,18 * * * pi /home/pi/bin/backup-home.sh nextcloud"
        # "*/15 * * * * root /run/current-system/sw/bin/cpupower frequency-set -g ondemand"
    ];
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable          = true;
    package         = pkgs.bluez;
  };

  hardware.pulseaudio = {
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  security.rtkit.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.virtualbox = {
    host.enable = false;
    # Enable the Oracle Extension Pack.
    host.enableExtensionPack = true;
  };

# programs.slock.enable       = true;
  # services.physlock.enable                      = true;

	  boot = {
      initrd.luks = {
        fido2Support = false;
        devices = {
          nvme = {
            preLVM = true;
            device = "/dev/disk/by-uuid/7a3362b0-cde4-4749-ab9f-08a6b07e8412";
          };
        };
      }; 
		  loader.systemd-boot.enable = true;
		  loader.efi.canTouchEfiVariables = true;
		  initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		  initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		  kernelModules                   = [ "tp_smapi" "acpi_call" ];
		  extraModulePackages             = [ config.boot.kernelPackages.tp_smapi config.boot.kernelPackages.acpi_call ];
		  extraModprobeConfig = ''
			  options acpi ec_no_wakeup=1
			  options thinkpad_acpi fan_control=1
		  '';
		  kernelPackages     = pkgs.linuxPackages_latest;
	  };

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart zerotierone.service
  '';

  networking = {
    # wlan0 is better b/c this is supposed to boot on different machines, and
    # consistent naming gets in the way b/c names are consistently different.
    usePredictableInterfaceNames = false;
    hostName        = "chatham";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/5673-6F9A"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/yuking/nix-root";        fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/yuking/home";            fsType = "ext4"; };
    "/home/data" = { device = "/dev/yuking/data";            fsType = "ext4"; };
  };

  nix.settings.max-jobs                     = lib.mkDefault 12;

  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion       = "21.11";
    autoUpgrade.enable = false;
  };

	nixpkgs.config = {
# TODO: undo and make package-specific exceptions: the error will guide you
		allowUnfree = true;
	  # allowBroken = true;
	};

}

