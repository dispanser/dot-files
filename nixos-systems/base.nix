{ pkgs, lib, ... }:

{
  nix.settings.trusted-users = [ "@wheel" ];
  # we need to watch this, but it sounds useful
  services.earlyoom.enable         = true;

  hardware.uinput.enable = true;
  services.udev = {
    enable = true;
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idModel}=="ThinkPad_Compact_USB_Keyboard_with_TrackPoint", TEST=="power/control", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{serial}=="*vial:f64c2b3c*", TEST=="power/control", ATTR{power/control}="on" KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
  };
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable             = true;
    enableSSHSupport   = true;
  };

  programs.bash.completion.enable = true;

  nix.settings = {
    auto-optimise-store = true;
    keep-outputs        = true;
    keep-derivations    = true;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  environment.systemPackages = with pkgs; [
    file
    lsof
    sysfsutils # for systool
    bridge-utils
    fd
    fzf
    inetutils
    keychain
    pass
    tmux
    wget
    w3m
    msr-tools
    inotify-tools
    bluez bluez-tools
    powerstat
    nvme-cli
    eza delta
    restic unison
    ripgrep
    neovim
    dialog
    patchelf
    wget
    htop iotop iftop psmisc
    stow
    gptfdisk parted hdparm smartmontools
    powertop acpi dmidecode
    ethtool
    lm_sensors lshw pciutils usbutils
    gnutls
    zip unzip p7zip rsnapshot
    gnupg offlineimap msmtp mutt mu
    i7z mprime fwupd s-tui
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };
  time.timeZone = "Europe/Berlin";

  programs.zsh.enable = true;
  programs.fish= {
    enable  = true;
    vendor = {
      functions.enable = true;
      completions.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups.pi = {};
    extraUsers.pi = {
      uid             = 1000;
      isNormalUser    = true;
      home            = "/home/pi";
      initialPassword = "wait,what?";
      description     = "Thomas Peiselt";
      group           = "pi";
      extraGroups     = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" "docker" "vboxusers" "adbusers" "input" "uinput" ];
      shell           = pkgs.fish;
    };
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 5;
    "vm.dirty_writeback_centisecs" = 2000;
  };
  boot.tmp.cleanOnBoot = true;

  nixpkgs.config.allowUnfree = true;
}
