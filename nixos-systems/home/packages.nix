{ pkgs, ... }:

with pkgs; let 
  darwinOnly = [
    openssh # override the ancient default install (TODO: could be homebrew'ed)
    goku
    pass # on linux, pass is installed system-wide because it can be used outside of my home context
    mc
    rclone
    rsync
    coreutils
    docker-credential-helpers
    restic unison
  ];
  desktopPkgs = [
    hueadm
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
    libnotify
    kanata
  ];
  develPkgs = [
    aider-chat
    llm
    docker
    kubectl
    zig
    marksman
    nil
    watchexec
    ctags
    sloc
    zellij
    hyperfine
    lua-language-server
    vscode-langservers-extracted
    samply
    k9s stern
    markdown-oxide
    bc
  ];
  linuxOnly = [
    touchscreen-gestures
    # these two work on darwin, but are unfree. also, slack is managed somehow else
    linuxPackages_latest.perf
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
    scrot 
    signal-desktop
    nextcloud-client
    firefox
    xfontsel
    xlsfonts
    xss-lock
    xvkbd
    ungoogled-chromium
    qutebrowser
    iotop
    onboard
  ];
in {
  desktopPkgs = desktopPkgs;
  develPkgs   = develPkgs;
  linuxOnly   = linuxOnly;
  darwinOnly  = darwinOnly;
}
  
