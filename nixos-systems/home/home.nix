{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  editor = "nvim";
  isServer = osConfig.networking.hostName == "tiny";
in
{

  sops = {
    # `nix-shell --run fish -p ssh-to-age age`
    # generate via `ssh-to-age -private-key -i  ~/.ssh/unison_tiny > ~/.config/sops/age/keys.txt`
    # `scp  ~/.config/sops/age/keys.txt tiny:.config/sops/age/keys.txt`
    # TBC: have a different key for every single host (based on its unique tiny key)
    # - right now, `.sops.yaml` uses host names to identif those
    age.keyFile = "/home/pi/.config/sops/age/keys.txt";

    # It's also possible to use a ssh key, but only when it has no password:
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  # toggle to false when sourcehut is down, as downloadeding from git.sr.ht/~rycee/nmd fails
  manual.html.enable = true;
  manual.manpages.enable = true;
  manual.json.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "slack"
    ];

  # systemd.user.sessionVariables = {
  home.sessionVariables = {
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
    ".psqlrc" = {
      enable = true;
      source = ../../configs/psql/.psqlrc;
    };
    ".cargo/config.toml" = lib.mkIf pkgs.stdenv.isLinux {
      text = ''
        [target.x86_64-unknown-linux-gnu]
        linker = "${pkgs.clang}/bin/clang"
        rustflags = [
          "-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"
        ]
      '';
    };
  };

  home.packages =
    let
      pkgSets = import ./packages.nix pkgs;
    in
    with pkgSets;
    desktopPkgs ++ develPkgs ++ (if pkgs.stdenv.isLinux then linuxOnly else darwinOnly);

  programs.fish.enable = true;
  imports = [
    (import ./fish.nix {
      pkgs = pkgs;
      editor = editor;
      config = config;
    })
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
    (import ./backup.nix { inherit isServer config; })
    (import ./unison.nix { inherit lib pkgs isServer; })
  ];

  services.touch.enable = !isServer;

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
    enable = !isServer && pkgs.stdenv.isLinux;
    detect-sleep = true;
    not-when-audio = true;
    not-when-fullscreen = false; # TBE
    environment = {
      PATH = "$PATH:/run/current-system/sw/bin";
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
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      defaultOptions = [
        ''--cycle''
        ''--layout=reverse''
        ''--border''
        ''--height=90%''
        ''--preview-window=wrap''
        ''--info=inline''
        ''--pointer="▶"''
        ''--marker="✗"''
        ''--bind "?:toggle-preview"''
        ''--bind "ctrl-a:select-all"''
      ];
    };

    bat = {
      enable = true;
      config = {
        theme = "Solarized (dark)";
      };
    };

    htop.enable = true;
    bottom.enable = true;
    dircolors.enable = true;
    home-manager.enable = true;
    jq.enable = true; # TODO: doesn't exist ?
  };

}
