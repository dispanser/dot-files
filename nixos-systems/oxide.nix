{ config, lib, pkgs,... }:

{
  # hardware.sensor.iio.bmi260.enable = true;
  services.joycond.enable = true;

  services.handheld-daemon = {
    enable = false;
    ui.enable = true;
    user = "pi";
  };

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
    ./cx_vpn.nix
  ];

  console.font = "sun12x22";

  # On my x12 libinput.touchpad is not applied to the touchpad, but using
  # libinput.mouse is applied.
  #   MatchIsTouchpad "on" in `xorg.conf` doesn't apply.
  services.libinput.mouse = {
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

  services.acpid = {
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    logEvents = true;
  };

  # nix shell with fido2luks
  # see https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2
  # HOSTNAME=(hostname) export FIDO2_LABEL="main @ $HOSTNAME"
  # sudo fido2luks -i add-key /dev/nvme0n1p1 <output of credentials>
  # regular pass + new salt + touch key
  boot = {
    initrd.luks = {
      fido2Support = false;
      devices = {
        oxide = {
          preLVM = true;
          device = "/dev/disk/by-uuid/c2aa7dd3-7c1c-4082-b8c0-be0bb5f5e358";
          fido2.credential = "0d05ca72aa2dd7ebba29a6467eef6bed84fbcd94cd34da3cff7c8dbaf3ee2d6e";
        };
      };
    }; 
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules                   = [ "coretemp" "tp_smapi" "acpi_call" "uinput" ];
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
    hostName        = "oxide";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      userControlled = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    firewall.enable = false;
  };

  fileSystems  = {
    # original boot partition including windows, which becaome too small: /dev/disk/by-uuid/EAAF-91D7
    "/boot"      = { device = "/dev/disk/by-uuid/3B4C-5ABE"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/oxide/nix-root";         fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/oxide/home";             fsType = "ext4"; neededForBoot = true;};
  };

  swapDevices = [
    {
      device = "/dev/oxide/swap";
      priority = 10;
    }
  ];

  nix.settings.max-jobs                     = lib.mkDefault 12;

  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion       = "25.05";
    autoUpgrade.enable = false;
  };

}

