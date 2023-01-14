{ pkgs, ... }:

let editor = "nvim";
in {

  systemd.user.sessionVariables = {
  # home.sessionVariables = {
    EDITOR = "${editor}";
  };

  home.username = "pi";
  home.homeDirectory = "/home/pi";

  home.stateVersion = "22.05";

  home.packages =
    let pkgSets =  import ./packages.nix pkgs;
    in with pkgSets; desktopPkgs ++ develPkgs;

    imports = [
      (import home/fish.nix { pkgs = pkgs; editor = editor; })
      home/git.nix
      home/helix.nix
      home/kitty.nix
      home/ssh.nix
      home/starship.nix
      home/tmux.nix
      home/xsuspender.nix
    ];
  services.notify-osd.enable = true;
  services.xidlehook = {
    enable         = true;
    # detect-sleep   = true;
    not-when-audio = false;
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

  programs = {

    direnv = {
      enable                  = true;
      nix-direnv.enable       = true;
    };

    mcfly = {
      enableFishIntegration = false;
      enable                = false;
      fuzzySearchFactor     = 2;
      keyScheme             = "vim";
      # fuzzySearchFactor      = 4;
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
        ''--bind "ctrl-y:execute-silent(echo {+} | xargs tmux setb)"'' 
        ''--bind "ctrl-e:execute(echo {+} | xargs -o nvim)"''
      ];
    };

    bat = {
      enable = true;
      config = {
        theme = "Solarized (dark)";
      };
    };

    wezterm = {
      enable = true;
    };

    alacritty = {
      enable = true;
    };

    htop.enable         = true;
    bottom.enable       = true;
    dircolors.enable    = true;
    home-manager.enable = true;
    jq.enable           = true; # TODO: doesn't exist ?
  };

}
