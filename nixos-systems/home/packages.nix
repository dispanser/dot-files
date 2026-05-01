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
    units
    feh
    entr
    zathura
    dmenu
    eza ripgrep neovim fzf fd
    iftop
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
    devenv
    docker
    kubectl
    zig
    marksman
    markdown-oxide
    nil
    watchexec
    ctags
    sloc
    lua-language-server
    vscode-langservers-extracted
    samply
    k9s stern
    bc
    teleport
    # uv
    tree-sitter
  ] ++ (with llm-agents; [ tilth rtk claude-code pi ]);
  linuxOnly = [
    brightnessctl
    touchscreen-gestures
    perf
    slack
    vlc
    pinentry-all
    simple-scan
    rofi
    scrot 
    signal-desktop
    nextcloud-client
    firefox
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
  
