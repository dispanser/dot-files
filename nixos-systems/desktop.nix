{ config, pkgs, ... }:

{
  imports = [ 
    ./base.nix 
    ./openssh.nix
  ];

  services.offlineimap = {
    enable = true;
    install = true;
    path = with pkgs; [ pass mu ];
  };

  # services.clipcat.enable = true;
  services.ddccontrol.enable = true;
  services.fstrim.enable = true;

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
    xkb = {
      layout                 = "us";
      options                = "caps:escape,compose:lwin-altgr,lv3:ralt_switch;terminate:ctrl_alt_bksp";
    };
    windowManager = {
      xmonad = {
        enable                 = true;
        enableContribAndExtras = true; 
      };
    };

    exportConfiguration = true;
  };

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.setxkbmap} setxkbmap -layout us -option -option caps:escape -option compose:lwin-altgr -option lv3:ralt_switch
    ${pkgs.xbindkeys}/bin/xbindkeys
    ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
  '';

  services.displayManager = {
    enable = true;
    defaultSession = "none+xmonad";
  };

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling   = true;
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
  hardware.trackpoint = {
    emulateWheel = true;
    enable = true;
    fakeButtons = false;
    speed = 150;       # default: 97
    sensitivity = 196; # default: 128
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-utils
    ];
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      inconsolata
      nerdfonts
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
