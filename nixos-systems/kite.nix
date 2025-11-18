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

  environment.systemPackages = with pkgs; [ radeontop lact ryzenadj ];
  console.font = "sun12x22";

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

  programs.ryzen-monitor-ng.enable = true;

  services.lact.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware = {
    amdgpu = {
      overdrive.enable = true;
      # overdrive.ppfeaturemask # check docs at some point in future
      initrd.enable = true;
      opencl.enable = true;
    };
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.rocminfo
      rocmPackages.amdsmi
    ];
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable          = true;
    package         = pkgs.bluez;
  };

  security.rtkit.enable = true;

  virtualisation.virtualbox = {
    host.enable = false;
    # Enable the Oracle Extension Pack.
    host.enableExtensionPack = true;
  };

  services.acpid = {
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    logEvents = true;
  };

  # systemd.tmpfiles.rules = [
  #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  # ];
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
    initrd.availableKernelModules   = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "amdgpu" ];
    initrd.kernelModules            = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "amdgpu" ];
    kernelModules                   = [ "tp_smapi" "acpi_call" "zenpower" "amdgpu" ];
    blacklistedKernelModules        = ["k10temp"];
    extraModulePackages             = with config.boot.kernelPackages; [
      tp_smapi acpi_call zenpower
    ];
    extraModprobeConfig = ''
      options acpi ec_no_wakeup=1
      options thinkpad_acpi fan_control=1
    '';
    kernelParams = [ 
      "amdgpu.gttsize=108000"
      "amdttm.pages_limit=27648000" 
      "amdttm.pagpage_pool_size=27648000"
      "ttm.pages_limit=27648000" 
      "ttm.pagpage_pool_size=27648000"
    ];
    kernelPackages     = pkgs.linuxPackages_latest;
  };

  powerManagement = {
    resumeCommands = ''
      ${pkgs.systemd}/bin/systemctl restart zerotierone.service
    '';
    powerDownCommands = ''
      ${pkgs.ethtool}/bin/ethtool -s eth0 wol g > /tmp/ethtool_up
    '';
  };

  # under test: this should re-apply the rule to disable auto-suspend for my keyboard(s)
  powerManagement.powertop.postStart = ''
    ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=17ef -a idProduct=6047
  '';

  networking = {
    # doesnt seem to work - maybe only first boot? Using ethtool directly in powerManagement.powerDownCommands.
    interfaces.eth0.wakeOnLan = {
      enable = true;
    };
    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    hostName        = "kite";
    wireless = {
      enable = false;
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

}

