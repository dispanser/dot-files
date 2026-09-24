{
  inputs,
  config,
  pkgs,
  lib,
  osConfig,
  isLinux ? true,
  ...
}:

let
  editor = "nvim";
  isServer = osConfig.networking.hostName == "tiny";
  isKite = osConfig.networking.hostName == "kite";
  cx_skills = inputs.cx-cli.packages.${pkgs.system}.skills;
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

  wayland.windowManager.niri = {
    enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
    systemd.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
  };

  # toggle to false when sourcehut is down, as downloadeding from git.sr.ht/~rycee/nmd fails
  manual.html.enable = true;
  manual.manpages.enable = true;
  manual.json.enable = true;

  home.sessionVariables = {
    EDITOR = "${editor}";
    VISUAL = "${editor}";
  };

  home.username = lib.mkDefault (if pkgs.stdenv.hostPlatform.isDarwin then "thomas.peiselt" else "pi");
  home.homeDirectory = lib.mkDefault (if pkgs.stdenv.hostPlatform.isDarwin then /Users/thomas.peiselt else /home/pi);

  home.stateVersion = "22.05";

  home.file = {
    "bin" = {
      source = ../../scripts;
      recursive = true;
    };
    "bin/darwin" = {
      source = ../../darwin-scripts;
      recursive = true;
      enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;
    };
    ".xbindkeysrc" = {
      enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
      source = ../../configs/xbindkeys/rc;
    };
    ".psqlrc" = {
      enable = true;
      source = ../../configs/psql/.psqlrc;
    };
    ".cargo/config.toml" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      text = ''
        [target.x86_64-unknown-linux-gnu]
        linker = "${pkgs.clang}/bin/clang"
        rustflags = [
          "-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"
        ]
      '';
    };
  } // lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/skills/${name}" { source = "${cx_skills}/${name}"; })
    (lib.filterAttrs (_: t: t == "directory") (builtins.readDir cx_skills));

  home.packages =
    let
      pkgSets = import ./packages.nix { inherit pkgs inputs; };
    in
    with pkgSets;
    desktopPkgs ++ develPkgs ++ (if pkgs.stdenv.hostPlatform.isLinux then linuxOnly else darwinOnly);

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
    ./inputplug.nix
    (import ./unison.nix { inherit lib pkgs isServer; })
  ] ++ lib.optionals isLinux [
    (import ./touch.nix { inherit lib pkgs osConfig; })
    ./voxtype.nix
  ] ++ (if isServer then [
    ./mail.nix
    ./backup.nix
    ./nextcloud.nix
  ] else []);


  services.inputplug.enable = pkgs.stdenv.hostPlatform.isLinux;

  services.notify-osd.enable = if pkgs.stdenv.hostPlatform.isLinux then true else false;

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
    enable = !isServer && !isKite && pkgs.stdenv.hostPlatform.isLinux;
    detect-sleep = true;
    not-when-audio = true;
    not-when-fullscreen = false; # TBE
    environment = {
      DISPLAY = ":0";
      XAUTHORITY = "/home/${config.home.username}/.Xauthority";
    };
    # TODO: xrandr brightness changes don't actually work because this script can't access :X
    timers = [
      {
        delay = 540;
        command = "${pkgs.brightnessctl}/bin/brightnessctl --save set 50%- >> /tmp/xih";
        canceller = "${pkgs.brightnessctl}/bin/brightnessctl --restore >> /tmp/xih";
      }
      {
        delay = 600;
        # hack: re-activate the screen briefly before suspend, otherwise kite can no longer see EDID
        # from LG display and falls back to VGA (or worse, requires a hard reset)
        command = "${pkgs.xset}/bin/xset dpms force on; ${pkgs.systemd}/bin/systemctl suspend >> /tmp/xih";
        canceller = "${pkgs.brightnessctl}/bin/brightnessctl --restore >> /tmp/xih";
      }
    ];
  };
  services.gpg-agent = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    maxCacheTtl = 18000;
    maxCacheTtlSsh = 18000;
  };

  programs = {
    fish.enable = true;
    atuin = {
      enable = true;
      package = pkgs.rustPlatform.buildRustPackage ({
        pname = "atuin";
        version = "18.13.6";

        src = pkgs.fetchFromGitHub {
          owner = "atuinsh";
          repo = "atuin";
          rev = "v18.13.6";
          hash = "sha256-yAw+ty6FUnFbiRTdAe2QQHzj6uU24fZ/bEIXcHl/thg=";
        };

        cargoHash = "sha256-jirVe0+N5+UHZWioj8AipUhawMBameqEJJpa8HPTnfw=";

        buildNoDefaultFeatures = true;
        buildFeatures = [
          "ai"
          "client"
          "clipboard"
          "daemon"
          "hex"
          "sync"
        ];

        nativeBuildInputs = [ pkgs.installShellFiles ];

        doCheck = false;

        postInstall = ''
          installShellCompletion --cmd atuin --bash <($out/bin/atuin gen-completions -s bash) --fish <($out/bin/atuin gen-completions -s fish) --zsh <($out/bin/atuin gen-completions -s zsh)
        '';
      });
      # daemon.enable = true;
      settings = {
        style = "full";
        search_mode = "fuzzy";
        filter_mode_shell_up_key_binding = "directory";
        dialect = "uk";
        update_check = false;
        show_preview = true;
        max_preview_height = 10;
        show_help = true;
        enableFishIntegration = true;
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
      historyWidget.command = "";
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
    jq.enable = true;
  } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    voxtype = {
      enable = true;
      configFile = ../../configs/voxtype.toml;
      package = pkgs.voxtype-vulkan;
    };
  };
}
