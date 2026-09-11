{ pkgs, inputs, ... }:

with pkgs; let 
  darwinOnly = [
    openssh # override the ancient default install (TODO: could be homebrew'ed)
    goku
    pass # on linux, pass is installed system-wide because it can be used outside of my home context
    mc
    rsync
    coreutils
    docker-credential-helpers
    unison
    openvpn
  ];
  desktopPkgs = [
    hueadm
    any-nix-shell
    units
    entr
    eza ripgrep neovim fzf fd
    iftop
    kanata
    sox
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
    # uv
    tree-sitter
    rustup
    inputs.cx-cli.packages.${pkgs.system}.default
  ] ++ (with inputs.llm-agents.packages.aarch64-darwin; [ tilth rtk pi ]);
  linuxOnly = [
    brightnessctl
    touchscreen-gestures
    voxtype-vulkan
    feh
    dmenu
    libnotify
    vial
    perf
    slack
    vlc
    pinentry-all
    simple-scan
    rofi
    scrot 
    signal-desktop
    nextcloud-client
    zathura
    firefox
    ungoogled-chromium
    qutebrowser
    iotop
    onboard
    wlr-randr xwayland-satellite fuzzel wtype wl-clipboard-rs
    yt-dlp
  ];
in {
  desktopPkgs = desktopPkgs;
  develPkgs   = develPkgs;
  linuxOnly   = linuxOnly;
  darwinOnly  = darwinOnly;
}
  
