{ config, lib, pkgs,... }:

{

  services.noctalia-shell.enable = true;

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
    ./unifi.nix
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

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      hosts = [
        "unix:///var/run/docker.sock"
        # "tcp://10.1.3.0:2375"
        # "tcp://0.0.0.0:2375"
      ];
    };
  };

  services.atd.enable   = true;
  services.fwupd.enable = true;
  security.pam.u2f.enable = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.firmware = with pkgs; [ 
    wireless-regdb 
  ];

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
        tiny = {
          preLVM = true;
          device = "/dev/disk/by-uuid/47da6f1e-3200-442b-9171-da5bdc1df818";
        };
        sanjota = {
          preLVM = true;
          device = "/dev/disk/by-uuid/afed8d0b-5948-4425-9c68-2b0352f3d4bd";
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
      enable = false;
      interfaces = [ "wlan0" ];
    };
    firewall = {
      enable = false;
      # attempt to block docker outside of VPN but this doesn't work
      extraInputRules = ''
        ip saddr 10.1.3.0/24 tcp dport 2375 accept
        tcp dport 2375 drop
        tcp dport 65423 accept # Keep SSH open
      '';
    };
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/C1AB-B00A"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/tiny/nix-root";          fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/tiny/home";              fsType = "ext4"; neededForBoot = true;};
    "/home/data" = { device = "/dev/sanjota/data";           fsType = "ext4"; neededForBoot = true; };
  };

  nix.settings.max-jobs                     = lib.mkDefault 8;

  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion       = "22.05";
    autoUpgrade.enable = false;
  };

}
