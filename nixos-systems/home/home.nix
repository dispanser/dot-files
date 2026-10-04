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
  cx_skills = inputs.cx-cli.packages.${pkgs.stdenv.hostPlatform.system}.skills;
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
      daemon.enable = true;
      settings = {
        style = "full";
        search_mode = "daemon-fuzzy";
        filter_mode_shell_up_key_binding = "directory";
        filters = [ "directory" "global" "host" "session" ];
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
