{ config, lib, pkgs,... }:

{
  imports = [
    ./desktop.nix
    ./zerotier.nix
    ./security.nix
    ./flakes.nix
    ./laptop.nix
	  ./brother.nix
    ./thinkfan.nix
  ];

  services.undervolt = {
    temp = 90;
    enable = false;
    useTimer = true;
    uncoreOffset = -50;
    gpuOffset = -45;
    coreOffset = -100;
    analogioOffset = -50;
    p1 = {
      limit = 29;
      window = 300;
    };
    p2 = {
      limit = 44;
      window = 56;
    };
  };

  virtualisation.docker.enable = true;

  services.espanso.enable = true;


  services.atd.enable   = true;
  services.fwupd.enable = true;

  services.fprintd.enable = true;
  security.pam.u2f.enable = true;

  # probably not necessary - the default value is that of config.services.fprintd.enable
  security.pam.services = {
    login.fprintAuth        = true;
    xscreensaver.fprintAuth = true;
    xlock.fprintAuth        = true;
    sudo.fprintAuth         = true;
  };

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
	  package         = pkgs.bluezFull;
  };

  hardware.pulseaudio = {
	  extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  security.rtkit.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  virtualisation.virtualbox = {
    host.enable = false;
    # Enable the Oracle Extension Pack.
    host.enableExtensionPack = true;
  };


  programs.fuse.userAllowOther = true;
# programs.slock.enable       = true;
  # services.physlock.enable                      = true;

  boot = {
    initrd.luks.devices = {
      epiphany = { 
        preLVM = true; 
        device = "/dev/disk/by-uuid/a5216110-3042-42fb-99e4-0ebc0de37258";
      }; 
    };
      # from https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/p14s/amd/gen2/default.nix 
      kernelParams = ["amdgpu.backlight=0" ];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules                   = [ "tp_smapi" "acpi_call" ];
      extraModulePackages             = [ config.boot.kernelPackages.tp_smapi config.boot.kernelPackages.acpi_call ];
      extraModprobeConfig = ''
        options acpi ec_no_wakeup=1
        options iwlwifi power_save=Y d0i3_disable=0
			  options thinkpad_acpi fan_control=1
      '';
      kernelPackages     = pkgs.linuxPackages_latest;
    };

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart zerotierone.service
    ${pkgs.coreutils}/bin/echo low > /sys/class/drm/card0/device/power_dpm_force_performance_level
  '';

  networking = {
    hostName        = "epiphany";
    usePredictableInterfaceNames = false;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"    = { device = "/dev/disk/by-uuid/DB6D-3788"; fsType = "vfat"; };
    "/"        = { device = "/dev/epiphany/nix-root";    fsType = "ext4"; };
    "/home"    = { device = "/dev/epiphany/home";          fsType = "ext4"; };
  };

  nix.settings.max-jobs                     = lib.mkDefault 16;

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

