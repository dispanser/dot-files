{ pkgs, lib, ... }:

let editor = "nvim";
in {

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
    "slack"
  ];

  systemd.user.sessionVariables = {
  # home.sessionVariables = {
    EDITOR = "${editor}";
  };

  home.username = "pi";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/pi" else "/home/pi";

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
  };

  home.packages =
    let pkgSets =  import ./packages.nix pkgs;
    in with pkgSets; desktopPkgs ++ develPkgs ++ (if pkgs.stdenv.isLinux then linuxOnly else darwinOnly);

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
      ./xsuspender.nix
    ];

  services.notify-osd.enable = if pkgs.stdenv.isLinux then true else false;

  # TBD - this is not perfect because it doesn't allow for actually editing these files
  xdg.configFile.nvim = {
    source = ../../nvim-config;
    recursive = true;
  };

  services.xidlehook = {
    enable           = if pkgs.stdenv.isLinux then true else false;
    # detect-sleep   = true;
    not-when-audio   = false;
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
      };
    };
    zoxide.enable = true;

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
