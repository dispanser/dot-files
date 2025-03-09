{ config, lib, pkgs,... }:

{
  imports = [
    ./laptop.nix
    ./desktop.nix
    ./zerotier.nix
    ./security.nix
    ./flakes.nix
    ./adguard_dns.nix
    ./brother.nix
    ./yubico.nix
    ./mqtt.nix
    ./smart-home.nix
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
    ];
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable          = true;
    package         = pkgs.bluez;
  };

  security.rtkit.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.virtualbox = {
    host.enable = false;
    # Enable the Oracle Extension Pack.
    host.enableExtensionPack = true;
  };

  boot = {
    initrd.luks = {
      fido2Support = false;
      devices = {
        sanjota = {
          preLVM = true;
          device = "/dev/disk/by-uuid/462786d0-1145-4540-9212-d14c8db7b341";
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
    usePredictableInterfaceNames = false;
    hostName        = "tiny";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/5658-E93A"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/sanjota/nix-root";       fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/sanjota/home";           fsType = "ext4"; neededForBoot = true;};
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
