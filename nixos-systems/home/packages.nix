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
    eza ripgrep neovim fzf fd
    iftop
    stow
    libnotify
    kanata
  ];
  develPkgs = [
    tuicr
    claude-code
    tabiew
    devenv
    nodejs # for copilot
    dig
    aider-chat
    devenv
    llm
    docker
    kubectl
    zig
    marksman
    markdown-oxide
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
    teleport
    mistral-vibe
    uv
  ];
  linuxOnly = [
    touchscreen-gestures
    perf
    slack
    vlc
    pinentry-all
    simple-scan
    xmodmap xev xbacklight xlockmore libxcb
    xbindkeys
    xclip xsel
    xmessage xdotool
    pavucontrol ponymix
    xinit
    rofi
    scrot 
    signal-desktop
    # nextcloud-client
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
  
