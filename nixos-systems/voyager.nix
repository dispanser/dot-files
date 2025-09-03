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
    # ./cx_vpn.nix
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

  hardware.cpu.amd.updateMicrocode = true;

  virtualisation.virtualbox = {
    host.enable = false;
    # Enable the Oracle Extension Pack.
    host.enableExtensionPack = true;
  };

  services.handheld-daemon = {
    enable = true;
    ui.enable = true;
    user = "pi";
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
      devices = {
        voyager = {
          preLVM = true;
          device = "/dev/disk/by-uuid/46d184c8-2989-4790-a5e0-f6f870fe1ff3";
        };
      };
    }; 
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules                   = [ "tp_smapi" "acpi_call" "kvm-amd" "zenpower" ];
    blacklistedKernelModules        = [ "k10temp" ];
    extraModulePackages             = [ config.boot.kernelPackages.tp_smapi config.boot.kernelPackages.acpi_call ];
    extraModprobeConfig = ''
    options acpi ec_no_wakeup=1
    options thinkpad_acpi fan_control=1
    options mt7921e disable_aspm=1
    '';
    kernelPackages     = pkgs.linuxPackages_latest;
    kernelParams = [
      "pcie_aspm=off"
    ];
  };

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart zerotierone.service
  '';

  networking = {

    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    hostName        = "voyager";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall.enable = false;
  };

  fileSystems  = {
    "/boot"      = { device = "/dev/disk/by-uuid/875A-3CD5"; fsType = "vfat"; neededForBoot = true;};
    "/"          = { device = "/dev/voyager/nix-root";       fsType = "ext4"; neededForBoot = true;};
    "/home"      = { device = "/dev/voyager/home";           fsType = "ext4"; neededForBoot = true;};
  };

  swapDevices = [
    {
      device = "/dev/voyager/swap";
      priority = 10;
    }
  ];

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

