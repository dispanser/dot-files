args@{ config, pkgs, lib, hasTouchScreen ? false, ... }:

let editor = "nvim";
in {

  # sourcehut is down, and nmd package cannot be downloaded from git.sr.ht/~rycee/nmd/....
  manual.html.enable = false;
  manual.manpages.enable = false;
  manual.json.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
    "slack"
  ];

  systemd.user.sessionVariables = {
  # home.sessionVariables = {
    EDITOR = "${editor}";
  };

  home.username = if pkgs.stdenv.isDarwin then "thomas.peiselt" else "pi";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/thomas.peiselt" else "/home/pi";

  home.stateVersion = "22.05";

  home.file = {
    "bin" = {
      source = ../../scripts;
      recursive = true;
    };
    "bin/darwin" = {
      source = ../../darwin-scripts;
      recursive = true;
      enable = lib.mkIf pkgs.stdenv.isDarwin true;
    };
    ".xbindkeysrc" = {
      enable = lib.mkIf pkgs.stdenv.isLinux true;
      source = ../../configs/xbindkeys/rc;
    };
    ".unison" = {
      enable = lib.mkIf pkgs.stdenv.isLinux true;
      source = ../../configs/unison;
      recursive = true;
    };
  };

  home.packages =
    let pkgSets =  import ./packages.nix pkgs;
    in with pkgSets; desktopPkgs ++ develPkgs ++ (if pkgs.stdenv.isLinux then linuxOnly else darwinOnly);

  programs.fish.enable = true;
  imports = [
    (import ./fish.nix { pkgs = pkgs; editor = editor; })
    ./alacritty.nix
    ./git.nix
    ./helix.nix
    ./kitty.nix
    ./qutebrowser.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./touch.nix
    ./inputplug.nix
    ./mail.nix
    ./unison.nix
  ];

  services.touch = {
    enable = hasTouchScreen;
    # if builtins.hasAttr hasTouchScreen args then args.hasTouchScreen else false;
    # lib.attrsets.attrByPath ["hasTouchScreen"] false args;
    finger-device = "Wacom HID 525C Finger";
    pen-device = "Wacom HID 525C Pen";
  };

  services.inputplug.enable = true;

  services.notify-osd.enable = if pkgs.stdenv.isLinux then true else false;

  # TBD - this is not perfect because it doesn't allow for actually editing these files
  xdg.configFile.nvim = {
    source = ../../nvim-config;
    recursive = true;
  };

  xdg.configFile.xmonad = {
    source = ../../xmonad-config/xmonad;
    recursive = true;
  };

  xdg.configFile."xmonad/lib" = {
    source = ../../xmonad-config/src;
    recursive = true;
  };

  services.xidlehook = {
    enable           = if pkgs.stdenv.isLinux then true else false;
    detect-sleep   = true;
    not-when-audio   = true;
    not-when-fullscreen = false; # TBE
    environment = {
      PATH    = "$PATH:/run/current-system/sw/bin";
      # DISPLAY = ''"$(xrandr | awk '/ connected/{print $1}')"'';
    };
    timers = [
      {
        delay = 240;
        command = "xrandr --output $DISPLAY --brightness .5 >> /tmp/xih";
        canceller = "xrandr --output $DISPLAY --brightness 1 >> /tmp/xih";
      }
      {
        delay = 270;
        command = "xrandr --output $DISPLAY --brightness .3 >> /tmp/xih";
        canceller = "xrandr --output $DISPLAY --brightness 1 >> /tmp/xih";
      }
      {
        delay = 300;
        command = "systemctl suspend >> /tmp/xih";
        canceller = "xrandr --output $DISPLAY --brightness 1 >> /tmp/xih";
      }
    ];
  };
  services.gpg-agent = {
    enable = if pkgs.stdenv.isLinux then true else false;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    maxCacheTtl = 18000;
    maxCacheTtlSsh = 18000;
  };

  programs = {
    atuin = {
      enable = true;
      settings = { 
        style = "full";
        search_mode = "fuzzy";
        filter_mode_shell_up_key_binding = "directory";
        dialect = "uk";
        update_check = false;
        show_preview = true;
        max_preview_height = 10;
        show_help = true;
        # cwd_filter = [ "${HOME}/projects/scratch" ];
      };
    };
    zoxide.enable = true;
    btop = { 
      enable = true;
      settings = {
        vim_keys = true;
      };
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    direnv = {
      enable                  = true;
      nix-direnv.enable       = true;
    };

    fzf = {
      enable = true;
      defaultOptions = [
        ''--cycle''
        ''--layout=reverse''
        ''-border''
        ''--height=90%''
        ''--preview-window=wrap''
        ''--info=inline''
        ''--pointer="▶"''
        ''--marker="✗"''
        ''--bind "?:toggle-preview"''
      ];
    };

    bat = {
      enable = true;
      config = {
        theme = "Solarized (dark)";
      };
    };

    htop.enable         = true;
    bottom.enable       = true;
    dircolors.enable    = true;
    home-manager.enable = true;
    jq.enable           = true; # TODO: doesn't exist ?
  };

}
