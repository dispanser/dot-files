{ config, pkgs, ... }:

with pkgs; let 
#  neovim = pkgs.neovim.override {
#    extraPythonPackages = pythonPkgs: [ pythonPkgs.sexpdata pythonPkgs.websocket_client ];
#  };
  desktopPkgs = [
    any-nix-shell
    simple-scan
    obsidian
    rofi
    spotify
    qutebrowser
    youtube-dl
    units
    scrot feh
    entr
    signal-desktop slack threema-desktop tdesktop
    pavucontrol ponymix
    nextcloud-client
    zathura
    firefox ungoogled-chromium
    dmenu
    mplayer
    rxvt_unicode 
    xbindkeys
    xclip xsel
    irssi
    pinentry
    xfontsel
    xorg.xmessage xdotool
    xlsfonts
    xss-lock
    xorg.xmodmap xorg.xev xorg.xbacklight xlockmore xorg.libxcb
    xvkbd
    pandoc
    xorg.xinit
  ];
  develPkgs = [
    watchexec
    ctags
    sloc
  ];
in {
  desktopPkgs = desktopPkgs;
  develPkgs   = develPkgs;
}
  
