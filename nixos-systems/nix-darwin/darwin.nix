{ pkgs, ... }:

{
  nix.enable = true;
  users.users."thomas.peiselt" = {
    home = "/Users/thomas.peiselt";
    name = "thomas.peiselt";
    shell = pkgs.fish;
    uid = 502;
  };

  imports = [
    ./kanata.nix
  ];

  system.primaryUser = "thomas.peiselt";
  users.knownUsers = [ "thomas.peiselt" ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim
    alacritty
    tmux
    openssh
    skhd
    colima
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "bluesnooze"
      "qutebrowser"
      "pritunl"
      "postman"
      "notion"
      "signal"
      "zerotier-one"
      "chatgpt"
      "stats"
      "teleport"
    ];
    brews = [
      "awscli"
      "golang"
      "openssh"
      "vcluster"
    ];
  };

  nix.settings = {
    trusted-users = [ "thomas.peiselt" ];
    experimental-features = "nix-command flakes";
    substituters = [
      "https://cache.nixos.org/"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:NxFbUAkVZoaMjRDxPIFohqjyThDObqvWwyDqXcB04pE="
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCommandAndLeftAlt = true;
    # apparently this also swaps side
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771302;
        HIDKeyboardModifierMappingDst = 30064771303;
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771303;
        HIDKeyboardModifierMappingDst = 30064771302;
      }
    ];
    remapCapsLockToEscape = true;
  };

  system.defaults.dock = {
    static-only = true;
    tilesize = 32;
    autohide = true;
    mru-spaces = false;
    # either requires a restart or is ignored, needed to modify dock settings
    mineffect = "scale";
  };
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # services.karabiner-elements.enable = true;

  services.yabai = {
    enable = true;
    config = {
      focus_follows_mouse = "autofocus";
      mouse_follows_focus = "on";
      window_placement = "second_child";
      # requires scripting addition and disabled system integrity protection
      window_opacity = "on";
      active_window_opacity = 1.0;
      normal_window_opacity = 0.5;
      layout = "bsp";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
      # a pretty orange, notable border
      active_window_border_color = "0xFFF77400";
      normal_window_border_color = "0x7f3535FF";
      window_border_width = 8;
      window_border = "on";
    };

    extraConfig = ''
      yabai -m space 1 --label code --layout stack
      yabai -m space 2 --label term --layout stack
      yabai -m space 3 --label tooling
      # first screen on laptop itself is empty so merging by unplugging the external display works
      yabai -m space 4 --label empty --layout stack
      yabai -m space 5 --label slack --layout stack

      yabai -m rule --add app='^Mail' space=mail
      yabai -m rule --add app='^Slack' space=slack
      yabai -m rule --add app='qutebrowser' space=slack
      yabai -m rule --add app='Pritunl' space=tooling
      yabai -m rule --add app='ChatGPT' space=slack

      yabai -m rule --add app='System Settings' manage=off
      yabai -m rule --add title='overlay' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Breakpoints' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Settings' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Evaluate' manage=off
    '';
  };
  launchd.daemons.unison = {
    script = ''
      ${pkgs.unison}/bin/unison \
        /Users/thomas.peiselt/src/github/coralogix/ \
        ssh://tiny//home/data/sync/home/pi/projects/coralogix/src \
        -repeat watch -auto -batch \
        -ignore="Name target" -ignore="Name .tp/targets" -ignore="Name build" -ignore="Name perf.data*" -ignore="Name debug"
    '';
    environment = {
    };
    path = with pkgs; [
      openssh
      unison-fsmonitor
    ];
    serviceConfig = {
      Disabled = true;
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/unison.log";
      StandardErrorPath = "/tmp/unison-error.log";
      UserName = "thomas.peiselt";
    };
  };

  services.skhd =
    let
      vStepSize = "120";
      # TODO: try to access the previously set values instead of re-defining, or let-bind it
      homeDir = "/Users/thomas.peiselt";
    in
    {
      enable = true;
      skhdConfig = ''
        # remap keys for basic sanity
        ralt - space : yabai -m window --focus recent
        ralt - h : yabai -m window --focus west
        ralt - j : yabai -m window --focus south
        ralt - k : yabai -m window --focus north
        ralt - l : yabai -m window --focus east
        ralt - 0x2B : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
        ralt - 0x2F : yabai -m window --focus stack.next || yabai -m window --focus stack.first

        ralt - c : yabai -m window --toggle float --grid 4:4:1:1:2:2
        ralt + shift - c : yabai -m window --toggle float --grid 6:6:1:1:4:4

        ctrl + ralt - z : ${homeDir}/bin/darwin/,y_float.fish 1:2:0:0:1:1
        ctrl + ralt - x : ${homeDir}/bin/darwin/,y_float.fish 1:2:1:0:1:1
        ctrl + ralt - f : ${homeDir}/bin/darwin/,y_float.fish 24:24:1:1:22:22
        ctrl + ralt - c : ${homeDir}/bin/darwin/,y_float.fish 4:4:1:1:2:2
        ctrl + ralt + shift - c : ${homeDir}/bin/darwin/,y_float.fish 6:6:1:1:4:4

        # for unknown reasons, the bindings below with alt + ralt don't work. other ones do, though!
        lalt + ralt - 0x2B : ${homeDir}/bin/darwin/,y_float.fish 1:2:0:0:1:1
        lalt + ralt - 0x2F : ${homeDir}/bin/darwin/,y_float.fish 1:2:1:0:1:1
        lalt + ralt - f : ${homeDir}/bin/darwin/,y_float.fish 24:24:1:1:22:22
        lalt + ralt - c : ${homeDir}/bin/darwin/,y_float.fish 4:4:1:1:2:2
        lalt + ralt + shift - c : ${homeDir}/bin/darwin/,y_float.fish 6:6:1:1:4:4
        ralt - 0x2C : yabai -m window --toggle split

        # swap window
        shift + ralt - x : yabai -m window --swap recent
        shift + ralt - h : yabai -m window --swap west
        shift + ralt - j : yabai -m window --swap south
        shift + ralt - k : yabai -m window --swap north
        shift + ralt - l : yabai -m window --swap east

        # move window
        shift + ctrl + ralt - h : yabai -m window --warp west
        shift + ctrl + ralt - j : yabai -m window --warp south
        shift + ctrl + ralt - k : yabai -m window --warp north
        shift + ctrl + ralt - l : yabai -m window --warp east

        # stack window
        ctrl + ralt - h : yabai -m window --stack west
        ctrl + ralt - j : yabai -m window --stack south
        ctrl + ralt - k : yabai -m window --stack north
        ctrl + ralt - l : yabai -m window --stack east

        # resize split(s)
        lalt + ralt - l : yabai -m window --resize right:${vStepSize}:0  || yabai -m window --resize left:${vStepSize}:0
        lalt + ralt - h : yabai -m window --resize right:-${vStepSize}:0  || yabai -m window --resize left:-${vStepSize}:0
        lalt + ralt - j : yabai -m window --resize bottom:0:${vStepSize}  || yabai -m window --resize top:0:${vStepSize}
        lalt + ralt - k : yabai -m window --resize bottom:0:-${vStepSize}  || yabai -m window --resize top:0:-${vStepSize}

        lalt + ralt - w : yabai -m window --resize top:0:-${vStepSize}  || yabai -m window --resize bottom:0:-${vStepSize}
        lalt + ralt - s : yabai -m window --resize top:0:${vStepSize}  || yabai -m window --resize bottom:0:${vStepSize}
        lalt + ralt - a : yabai -m window --resize left:-${vStepSize}:0  || yabai -m window --resize right:-${vStepSize}:0
        lalt + ralt - d : yabai -m window --resize left:${vStepSize}:0  || yabai -m window --resize right:${vStepSize}:0

        ralt - f : yabai -m window --toggle zoom-fullscreen
        ralt + shift - f : yabai -m window --toggle zoom-parent

        # switch display monitor
        ralt + shift - r  : yabai -m window --space recent
        ralt + shift - 1  : yabai -m window --space 1
        ralt + shift - 2  : yabai -m window --space 2
        ralt + shift - 3  : yabai -m window --space 3
        ralt + shift - 4  : yabai -m window --space 4
        ralt + shift - 5  : yabai -m window --space 5
        ralt + shift - 6  : yabai -m window --space 6
        ralt + shift - 0x21  : yabai -m window --space prev
        ralt + shift - 0x1E  : yabai -m window --space next

        # display stuff
        ralt - s  : yabai -m display --focus next || yabai -m display --focus prev
        fn - s  : pmset sleepnow
        ralt + shift - s  : yabai -m window --display recent && yabai -m display --focus recent

        # ralt - r  : yabai -m space --focus recent # not without scripting additions :-(
        # ralt + shift - t : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')

        ralt - b : ${homeDir}/bin/darwin/,y_focus.fish "Firefox"
        ralt - 0x29 : ${homeDir}/bin/darwin/,y_focus.fish "qutebrowser"

        ralt - m : ${homeDir}/bin/darwin/,y_focus.fish "Slack"
        ralt - a : ${homeDir}/bin/darwin/,y_focus.fish "ChatGPT"
        ralt + shift - m : ${homeDir}/bin/darwin/,y_focus.fish "Signal"
        ralt - z : ${homeDir}/bin/darwin/,y_focus.fish "zoom.us"
        ralt - v : ${homeDir}/bin/darwin/,y_focus.fish "Pritunl"

        ralt - g : ${homeDir}/bin/darwin/,y_overlay.fish  /Applications/ChatGPT.app/Contents/MacOS/ChatGPT global
        ralt - o : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty overlay >> /tmp/tpx
        ralt - t : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty main >> /tmp/tpx
        ralt + shift - o : ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope overlay
        ralt + shift - t : ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope main
        ralt - return: ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope main --workspace code

        # typing
        fn - t : ${pkgs.skhd}/bin/skhd -t "thomas.peiselt@coralogix.com"
        0x0A : ${pkgs.skhd}/bin/skhd -t "`"
        shift - 0x0A : ${pkgs.skhd}/bin/skhd -t "~"
      '';
    };

}
