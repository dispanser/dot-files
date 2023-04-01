{ config, pkgs, ... }:

with pkgs; let 
#  neovim = pkgs.neovim.override {
#    extraPythonPackages = pythonPkgs: [ pythonPkgs.sexpdata pythonPkgs.websocket_client ];
#  };
  darwinOnly = [
    openssh
    goku
    pass # on linux, pass is installed system-wide because it can be used outside of my home context
  ];
  desktopPkgs = [
    any-nix-shell
    obsidian
    youtube-dl
    units
    feh
    entr
    slack
    zathura
    dmenu
    mplayer
    pinentry
    pandoc
    exa delta ripgrep neovim fzf fd
    iftop
    stow
  ];
  develPkgs = [
    watchexec
    ctags
    sloc
  ];
  linuxOnly = [
    simple-scan
    xorg.xmodmap xorg.xev xorg.xbacklight xlockmore xorg.libxcb
    xbindkeys
    xclip xsel
    xorg.xmessage xdotool
    pavucontrol ponymix
    xorg.xinit
    rofi
    spotify
    scrot 
    signal-desktop threema-desktop tdesktop
    nextcloud-client
    firefox
    xfontsel
    xlsfonts
    xss-lock
    xvkbd
    ungoogled-chromium
    qutebrowser
    iotop
  ];
in {
  desktopPkgs = desktopPkgs;
  develPkgs   = develPkgs;
  linuxOnly   = linuxOnly;
  darwinOnly  = darwinOnly;
}
  
