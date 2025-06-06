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
    # ./cx_vpn.nix
  ];

  console.font = "sun12x22";

  services.libinput.mouse = {
    disableWhileTyping = true;
    clickMethod        = "buttonareas";
    tapping            = false;
  };

  services.handheld-daemon = {
    enable = true;
    ui.enable = true;
    user = "pi";
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

  programs.ryzen-monitor-ng.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
    amdvlk.enable = true;
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

  services.acpid = {
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    logEvents = true;
  };

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # nix shell with fido2luks
  # see https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2
  # HOSTNAME=(hostname) export FIDO2_LABEL="main @ $HOSTNAME"
  # sudo fido2luks -i add-key /dev/nvme0n1p1 <output of credentials>
  # regular pass + new salt + touch key
  boot = {
    initrd.luks = {
      fido2Support = true;
      devices = {
        konsole = {
          preLVM = true;
          device = "/dev/disk/by-uuid/65693a87-f256-4644-aaa1-262594df19a1";
          # fido2.credential = "0d05ca72aa2dd7ebba29a6467eef6bed84fbcd94cd34da3cff7c8dbaf3ee2d6e";
        };
      };
    }; 
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules                   = [ "tp_smapi" "acpi_call" "zenpower" ];
    blacklistedKernelModules        = ["k10temp"];
    extraModulePackages             = with config.boot.kernelPackages; [
      tp_smapi acpi_call zenpower
    ];
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
    hostName        = "konsole";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/823C-633A"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/konsole/nix-root";       fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/konsole/home";           fsType = "ext4"; neededForBoot = true;};
  };

  swapDevices = [
    {
      device = "/dev/konsole/swap";
      priority = 10;
    }
  ];

  nix.settings.max-jobs                     = lib.mkDefault 8;

  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion       = "24.11";
    autoUpgrade.enable = false;
  };

	nixpkgs.config = {
# TODO: undo and make package-specific exceptions: the error will guide you
		allowUnfree = true;
	};

}

