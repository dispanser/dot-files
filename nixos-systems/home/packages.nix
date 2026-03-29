{ pkgs, llm-agents, ... }:

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
    vial
    sox
    voxtype-vulkan
  ];
  develPkgs = [
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
    uv
    lazygit
  ] ++ (with llm-agents; [ tuicr tilth rtk claude-code pi ]);
  linuxOnly = [
    brightnessctl
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
    wlr-randr xwayland-satellite fuzzel wtype wl-clipboard-rs
  ];
in {
  desktopPkgs = desktopPkgs;
  develPkgs   = develPkgs;
  linuxOnly   = linuxOnly;
  darwinOnly  = darwinOnly;
}
  
