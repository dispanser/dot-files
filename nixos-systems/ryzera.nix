{ config, lib, pkgs,... }:

{
  services.joycond.enable = true;

  imports = [
    ./laptop.nix
    ./desktop.nix
    ./zerotier.nix
    ./security.nix
    ./flakes.nix
    ./adguard_dns.nix
    ./brother.nix
    ./yubico.nix
    ./fingerprint.nix
    ./lowmem.nix
  ];
  console.font = "sun12x22";

  # On my x12 libinput.touchpad is not applied to the touchpad, but using
  # libinput.mouse is applied.
  #   MatchIsTouchpad "on" in `xorg.conf` doesn't apply.
  services.xserver.libinput.mouse = {
    disableWhileTyping = true;
    clickMethod        = "buttonareas";
    tapping            = false;
  };

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

  services.espanso.enable = false;
  services.atd.enable   = true;
  services.fwupd.enable = true;
  security.pam.u2f.enable = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.sensor.iio.enable = true;

  hardware.firmware = with pkgs; [ 
    wireless-regdb 
  ];

  services.cron = {
	  enable         = false;
	  systemCronJobs = [
	      "17 10,21 * * * pi /home/pi/bin/backup-home.sh local"
	      "17 12 * * * pi /home/pi/bin/backup-home.sh backblaze"
        "17 11,18 * * * pi /home/pi/bin/backup-home.sh nextcloud"
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

  services.acpid = {
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    logEvents = true;
  };

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # nix shell with fido2luks
  # HOSTNAME=(hostname) export FIDO2_LABEL="main @ $HOSTNAME"
  # sudo fido2luks -i add-key /dev/nvme0n1p1 <output of credentials>
  # regular pass + new salt + touch key
  boot = {
    initrd.luks = {
      fido2Support = true;
      devices = {
        ryzera = {
          preLVM = true;
          device = "/dev/disk/by-uuid/a6bdd622-bee0-43d2-8efd-3b1cc2b0b68e";
          fido2.credential = "0d05ca72aa2dd7ebba29a6467eef6bed84fbcd94cd34da3cff7c8dbaf3ee2d6e";
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

    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    hostName        = "ryzera";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/A1D6-7869"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/ryzera/nix-root";           fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/ryzera/home";               fsType = "ext4"; neededForBoot = true;};
  };

  nix.settings.max-jobs                     = lib.mkDefault 8;

  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion       = "22.05";
    autoUpgrade.enable = false;
  };

	nixpkgs.config = {
# TODO: undo and make package-specific exceptions: the error will guide you
		allowUnfree = true;
	  # allowBroken = true;
	};

}
