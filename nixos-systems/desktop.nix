{ config, pkgs, ... }:

{
  imports = [ 
    ./base.nix 
    ./openssh.nix
  ];

  services.ddccontrol.enable = true;
  services.fstrim.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    ## pulled in via offlineimap. Not using kerberos, so hopefully OK?
    "python3.10-kerberos-1.3.1"
    "electron-13.6.9"
  ];
 
  # required for pipewire
  sound.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  environment.variables = {
    GTK_IM_MODULE = "xim";
    QT_IM_MODULE = "xim";
  };

  # also re-use xkb config for console keyboards (tbd)
  console.useXkbConfig = true;
  # Enable the X11 windowing system.
  services.xserver = {
    enable                 = true;
    enableCtrlAltBackspace = true;
    layout                 = "us";
    xkbOptions             = "caps:escape,compose:lwin-altgr,lv3:ralt_switch;terminate:ctrl_alt_bksp";
    windowManager = {
      xmonad = {
        enable                 = true;
        enableContribAndExtras = true; 
      };
    };

    displayManager = {
      sessionCommands = ''
        ${pkgs.xbindkeys}/bin/xbindkeys
        ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
      '';
      defaultSession = "none+xmonad";
    };
    libinput = {
      enable = true;
      touchpad = {
# naturalScrolling   = true;
        disableWhileTyping = true;
        clickMethod        = "buttonareas";
        tapping            = false;
        scrollButton       = 3;
        additionalOptions = ''
# prevents too many unintentional clicks
          Option "PalmDetect" "1"

# "natural" vertical and horizontal scrolling
          Option "VertTwoFingerScroll" "1"
          Option "VertScrollDelta" "-75"
          Option "HorizTwoFingerScroll" "1"
          Option "HorizScrollDelta" "-75"

          Option "MinSpeed" "1"
          Option "MaxSpeed" "1"

          Option "AccelerationProfile" "2"
          Option "ConstantDeceleration" "4"
          '';
      };
    };
    exportConfiguration = true;
  };
  hardware.trackpoint = {
    emulateWheel = true;
    enable = true;
    fakeButtons = false;
    speed = 150;       # default: 97
    sensitivity = 196; # default: 128
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-utils
    ];
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      nerdfonts
      inconsolata
      ubuntu_font_family
      anonymousPro
      dejavu_fonts
      liberation_ttf
      proggyfonts
      source-sans-pro
      terminus_font
      terminus_font_ttf
      ttf_bitstream_vera
    ];
  };

}
