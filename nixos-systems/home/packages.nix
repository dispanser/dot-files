{ config, pkgs, ... }:

with pkgs; let 
#  neovim = pkgs.neovim.override {
#    extraPythonPackages = pythonPkgs: [ pythonPkgs.sexpdata pythonPkgs.websocket_client ];
#  };
  darwinOnly = [
    openssh # override the ancient default install (TODO: could be homebrew'ed)
    goku
    pass # on linux, pass is installed system-wide because it can be used outside of my home context
    mc
    google-cloud-sdk
    rclone
    rsync
    coreutils
    k9s stern
  ];
  desktopPkgs = [
    any-nix-shell
    yt-dlp
    units
    feh
    entr
    zathura
    dmenu
    pandoc
    eza delta ripgrep neovim fzf fd
    iftop
    stow
  ];
  develPkgs = [
    zig
    marksman
    nil
    watchexec
    ctags
    sloc
    zellij
    hyperfine
    lua-language-server
  ];
  linuxOnly = [
    # these two work on darwin, but are unfree. also, slack is managed somehow else
    slack obsidian
    vlc
    pinentry
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
    signal-desktop tdesktop
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
  
