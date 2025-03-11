{ pkgs, ... }:

{
  nix.enable = true;
  users.users."thomas.peiselt" = {
    home = "/Users/thomas.peiselt";
    name = "thomas.peiselt";
    shell = pkgs.fish;
    uid = 502;
  };

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
      "obsidian"
      "notion"
      "signal"
      "zerotier-one"
      "chatgpt"
      "stats"
    ];
    brews = [
      "awscli"
      "golang"
      "openssh"
      "llama.cpp"
    ];
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
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
    remapCapsLockToEscape = true;
    # TODO: does not work for the ThinkPad Keyboard II - no tilde at all
    nonUS.remapTilde = false;
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
      window_placement    = "second_child";
      # requires scripting addition and disabled system integrity protection
      window_opacity      = "on";
      active_window_opacity = 1.0;
      normal_window_opacity = 0.5;
      layout              = "bsp";
      top_padding         = 10;
      bottom_padding      = 10;
      left_padding        = 10;
      right_padding       = 10;
      window_gap          = 10;
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
# /nix/store/cs65zlcmqzhhy0khkm15b56li1cq022n-unison-2.53.7/bin/unison -auto=true -batch=true -ignore=Name *.o -ignore=Name *.hi -ignore=Name xmonad-x86_64-linux -ignore=Name *.class -ignore=Name *.jar -ignore=Name .password-store/.git -ignore=Name personal/diary/.git -ignore=Name src/github/dispanser/dot-files -ignore=Name src/github/dispanser/partition-index/.git -ignore=Name target -ignore=Name build -ignore=Name debug -ignore=Name .gradle -ignore=Name .cache -ignore=Name .chromium -ignore=Name .stack-work -ignore=Name .qute/cache -ignore=Name .qute/data -ignore=Name .qute/runtime -ignore=Name *.log -ignore=Name .direnv -ignore=Name .devenv -ignore=Name _internal.abi3.so -ignore=Name __pycache__ -log=false -path=projects -path=src -path=.password-store -prefer=newer -repeat=watch -sshcmd=/nix/store/d47m463xavp70bgzm8qk90fb2a7w79b4-openssh-9.9p1/bin/ssh -ui=text /home/pi/ ssh://tiny//home/data/sync/home/pi/
  launchd.daemons.unison = {
    script = ''
      ${pkgs.unison}/bin/unison \
        /Users/thomas.peiselt/src/github/coralogix/ \
        ssh://tiny//home/data/sync/home/pi/projects/coralogix/src \
        -repeat watch -auto -batch \
        -ignore="Name target" -ignore="Name .tp/targets" -ignore="Name build" -ignore="Name debug"
      '';
    environment = {
    };
    path = with pkgs; [ openssh unison-fsmonitor ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/unison.log";
      StandardErrorPath = "/tmp/unison-error.log";
      UserName = "thomas.peiselt";
    };
  };

  services.skhd = let
    vStepSize = "120";
    hStepSize = "80";
    # TODO: try to access the previously set values instead of re-defining, or let-bind it
    homeDir = "/Users/thomas.peiselt";
  in {
    enable = true;
    skhdConfig = ''
      # remap keys for basic sanity
      rcmd - space : yabai -m window --focus recent
      rcmd - h : yabai -m window --focus west
      rcmd - j : yabai -m window --focus south
      rcmd - k : yabai -m window --focus north
      rcmd - l : yabai -m window --focus east
      rcmd - 0x2B : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
      rcmd - 0x2F : yabai -m window --focus stack.next || yabai -m window --focus stack.first

      rcmd - c : yabai -m window --toggle float --grid 4:4:1:1:2:2
      rcmd + shift - c : yabai -m window --toggle float --grid 6:6:1:1:4:4

      ctrl + rcmd - z : ${homeDir}/bin/darwin/,y_float.fish 1:2:0:0:1:1
      ctrl + rcmd - x : ${homeDir}/bin/darwin/,y_float.fish 1:2:1:0:1:1
      ctrl + rcmd - f : ${homeDir}/bin/darwin/,y_float.fish 24:24:1:1:22:22
      ctrl + rcmd - c : ${homeDir}/bin/darwin/,y_float.fish 4:4:1:1:2:2
      ctrl + rcmd + shift - c : ${homeDir}/bin/darwin/,y_float.fish 6:6:1:1:4:4

      # for unknown reasons, the bindings below with alt + rcmd don't work. other ones do, though!
      alt + rcmd - 0x2B : ${homeDir}/bin/darwin/,y_float.fish 1:2:0:0:1:1
      alt + rcmd - 0x2F : ${homeDir}/bin/darwin/,y_float.fish 1:2:1:0:1:1
      alt + rcmd - f : ${homeDir}/bin/darwin/,y_float.fish 24:24:1:1:22:22
      alt + rcmd - c : ${homeDir}/bin/darwin/,y_float.fish 4:4:1:1:2:2
      alt + rcmd + shift - c : ${homeDir}/bin/darwin/,y_float.fish 6:6:1:1:4:4
      rcmd - 0x2C : yabai -m window --toggle split

      # swap window
      shift + rcmd - x : yabai -m window --swap recent
      shift + rcmd - h : yabai -m window --swap west
      shift + rcmd - j : yabai -m window --swap south
      shift + rcmd - k : yabai -m window --swap north
      shift + rcmd - l : yabai -m window --swap east

      # move window
      shift + ctrl + rcmd - h : yabai -m window --warp west
      shift + ctrl + rcmd - j : yabai -m window --warp south
      shift + ctrl + rcmd - k : yabai -m window --warp north
      shift + ctrl + rcmd - l : yabai -m window --warp east

      # stack window
      ctrl + rcmd - h : yabai -m window --stack west
      ctrl + rcmd - j : yabai -m window --stack south
      ctrl + rcmd - k : yabai -m window --stack north
      ctrl + rcmd - l : yabai -m window --stack east

      # resize split(s)
      alt + rcmd - l : yabai -m window --resize right:${vStepSize}:0  || yabai -m window --resize left:${vStepSize}:0
      alt + rcmd - h : yabai -m window --resize right:-${vStepSize}:0  || yabai -m window --resize left:-${vStepSize}:0
      alt + rcmd - j : yabai -m window --resize bottom:0:${vStepSize}  || yabai -m window --resize top:0:${vStepSize}
      alt + rcmd - k : yabai -m window --resize bottom:0:-${vStepSize}  || yabai -m window --resize top:0:-${vStepSize}

      alt + rcmd - w : yabai -m window --resize top:0:-${vStepSize}  || yabai -m window --resize bottom:0:-${vStepSize}
      alt + rcmd - s : yabai -m window --resize top:0:${vStepSize}  || yabai -m window --resize bottom:0:${vStepSize}
      alt + rcmd - a : yabai -m window --resize left:-${vStepSize}:0  || yabai -m window --resize right:-${vStepSize}:0
      alt + rcmd - d : yabai -m window --resize left:${vStepSize}:0  || yabai -m window --resize right:${vStepSize}:0

      rcmd - f : yabai -m window --toggle zoom-fullscreen
      rcmd + shift - f : yabai -m window --toggle zoom-parent

      # switch display monitor
      rcmd + shift - r  : yabai -m window --space recent
      rcmd + shift - 1  : yabai -m window --space 1
      rcmd + shift - 2  : yabai -m window --space 2
      rcmd + shift - 3  : yabai -m window --space 3
      rcmd + shift - 4  : yabai -m window --space 4
      rcmd + shift - 5  : yabai -m window --space 5
      rcmd + shift - 6  : yabai -m window --space 6
      rcmd + shift - 0x21  : yabai -m window --space prev
      rcmd + shift - 0x1E  : yabai -m window --space next

      # display stuff
      rcmd - s  : yabai -m display --focus next || yabai -m display --focus prev
      fn - s  : pmset sleepnow
      rcmd + shift - s  : yabai -m window --display recent && yabai -m display --focus recent

      # rcmd - r  : yabai -m space --focus recent # not without scripting additions :-(
      # rcmd + shift - t : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')

      rcmd - b : ${homeDir}/bin/darwin/,y_focus.fish "Firefox"
      rcmd - 0x29 : ${homeDir}/bin/darwin/,y_focus.fish "qutebrowser"

      rcmd - m : ${homeDir}/bin/darwin/,y_focus.fish "Slack"
      rcmd - a : ${homeDir}/bin/darwin/,y_focus.fish "ChatGPT"
      rcmd + shift - m : ${homeDir}/bin/darwin/,y_focus.fish "Signal"
      rcmd - z : ${homeDir}/bin/darwin/,y_focus.fish "zoom.us"
      rcmd - v : ${homeDir}/bin/darwin/,y_focus.fish "Pritunl"

      rcmd - g : ${homeDir}/bin/darwin/,y_overlay.fish  /Applications/ChatGPT.app/Contents/MacOS/ChatGPT global
      rcmd - o : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty overlay >> /tmp/tpx
      rcmd - t : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty main >> /tmp/tpx
      rcmd + shift - o : ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope overlay
      rcmd + shift - t : ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope main
      rcmd - return: ${homeDir}/src/github/dispanser/yabars/.devenv/state/cargo-install/bin/yabars tmux-term --scope main --workspace code

      # typing
      fn - t : ${pkgs.skhd}/bin/skhd -t "thomas.peiselt@coralogix.com"
      0x0A : ${pkgs.skhd}/bin/skhd -t "`"
      shift - 0x0A : ${pkgs.skhd}/bin/skhd -t "~"
    '';
  };
}
