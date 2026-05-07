{ config, lib, pkgs, ... }:

{
  services.joycond.enable = true;
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
    ./fingerprint.nix
    ./lowmem.nix
  ];

  nixpkgs.config.nvidia.acceptLicense = true;

  console.font = "sun12x22";

  services.handheld-daemon = {
    enable = false;
    ui.enable = true;
    user = "pi";
  };

  # On some machines the touchpad does not pick up the touchpad settings,
  # but the mouse section still applies.
  services.libinput.mouse = {
    disableWhileTyping = true;
    clickMethod = "buttonareas";
    tapping = false;
  };

  virtualisation.docker.enable = true;

  services.atd.enable = true;
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
    enable = true;
    package = pkgs.bluez;
  };

  security.rtkit.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware = {
    nvidia = {
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;
    };
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  virtualisation.virtualbox = {
    host.enable = false;
    host.enableExtensionPack = true;
  };

  services.acpid = {
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    logEvents = true;
  };

  boot = {
    initrd.luks = {
      fido2Support = false;
      devices = {
        tachi = {
          preLVM = true;
          device = "/dev/disk/by-uuid/4015b20a-3a4d-4e79-b4eb-a1f0ff226450";
        };
      };
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "amdgpu" ];
    initrd.kernelModules = [ "xhci_pci" "uas" "usbhid" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "amdgpu" ];
    kernelModules = [ "tp_smapi" "acpi_call" "uinput" "amdgpu" "nvidia" "nvidia_uvm" "kvm-amd" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi config.boot.kernelPackages.acpi_call ];
    extraModprobeConfig = ''
      options acpi ec_no_wakeup=1
      options thinkpad_acpi fan_control=1
      options usbcore autosuspend=-1
      options mt7921e disable_aspm=1
    '';
    kernelParams = [
      "pcie_aspm=off"
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.shrinker_enabled=1"
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=0"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart zerotierone.service
  '';

  networking = {
    enableIPv6 = false;
    # external / rescue system: this should adapt across varying NIC names
    usePredictableInterfaceNames = false;
    hostName = "tachi";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      userControlled = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    firewall.enable = false;
  };

  fileSystems = {
    "/boot" = { device = "/dev/disk/by-uuid/FCD4-2D42"; fsType = "vfat"; neededForBoot = true; };
    "/" = { device = "/dev/tachi/nix-root"; fsType = "ext4"; neededForBoot = true; };
    "/home" = { device = "/dev/tachi/home"; fsType = "ext4"; neededForBoot = true; };
  };

  nix.settings.max-jobs = lib.mkDefault 8;

  system = {
    stateVersion = "22.05";
    autoUpgrade.enable = false;
  };
}
