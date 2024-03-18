{ pkgs, ... }:

{
  users.users."thomas.peiselt" = {
    home = "/Users/thomas.peiselt";
    name = "thomas.peiselt";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
    neovim
    alacritty
    tmux
    openssh
  ];
 
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "qutebrowser"
      "docker"
      "pritunl"
      "postman"
      "obsidian"
      "notion"
    ];
    brews = [
      "awscli"
      "golang"
      "openssh"
      "docker-compose"
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;
 
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
  security.pam.enableSudoTouchIdAuth = true;
 
  services.karabiner-elements.enable = true;
 
  services.yabai = {
    enable = true;
    config = {
      focus_follows_mouse = "autoraise";
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
      yabai -m space 1 --label code
      yabai -m space 2 --label term
      yabai -m space 3 --label docs
      yabai -m space 4 --label slack
      yabai -m space 5 --label mail
      yabai -m space 6 --label zoom
 
      yabai -m rule --add app='^Mail' space=mail
      # yabai -m rule --add app='^Slack' space=slack
      yabai -m rule --add app='^zoom.us' space=zoom
 
      yabai -m rule --add app='System Settings' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Breakpoints' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Settings' manage=off
      yabai -m rule --add app='IntelliJ IDEA' title='Evaluate' manage=off
      yabai -m rule --add app='Obsidian' manage=off grid=4:4:1:1:2:2 border=off
      yabai -m rule --add app='Alacritty' manage=off grid=4:4:1:1:2:2 border=off
      yabai -m rule --add app='Slack' manage=off grid=6:6:1:1:4:4 border=off
      yabai -m rule --add app='kitty' manage=off grid=6:6:3:0:3:5 border=off
    '';
  };
 
  services.skhd = let
<<<<<<< HEAD
    vStepSize = "200";
    hStepSize = "150";
    # TODO: try to access the previously set values instead of re-defining, or let-bind it
    homeDir = "/Users/thomas.peiselt";
=======
    vStepSize = "200" ;
    hStepSize = "150";
>>>>>>> bbec325 ([nix/darwin] Make nix-darwin + home manager work again)
  in {
    enable = true;
    skhdConfig = ''
      # remap keys for basic sanity
      0x0A : ${pkgs.skhd}/bin/skhd -t "`"
      shift - 0x0A : ${pkgs.skhd}/bin/skhd -t "~"
      rcmd - space : yabai -m window --focus recent
      rcmd - h : yabai -m window --focus west
      rcmd - j : yabai -m window --focus south
      rcmd - k : yabai -m window --focus north
      rcmd - l : yabai -m window --focus east
      rcmd - 0x2B : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
      rcmd - 0x2F : yabai -m window --focus stack.next || yabai -m window --focus stack.first
 
<<<<<<< HEAD
=======
      rcmd - t : /Users/pi/bin/darwin/,y_focus_or_create_local.fish Alacritty ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty
>>>>>>> bbec325 ([nix/darwin] Make nix-darwin + home manager work again)
      rcmd - c : yabai -m window --toggle float --grid 4:4:1:1:2:2
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
      alt + rcmd - h : yabai -m window --stack west
      alt + rcmd - j : yabai -m window --stack south
      alt + rcmd - k : yabai -m window --stack north
      alt + rcmd - l : yabai -m window --stack east
 
      # # resize split(s)
      # yabai -m window --resize right:-20:0
      lctrl + rcmd - l : yabai -m window --resize right:${vStepSize}:0  || yabai -m window --resize left:${vStepSize}:0
      lctrl + rcmd - h : yabai -m window --resize right:-${vStepSize}:0  || yabai -m window --resize left:-${vStepSize}:0
      lctrl + rcmd - j : yabai -m window --resize bottom:0:${vStepSize}  || yabai -m window --resize top:0:${vStepSize}
      lctrl + rcmd - k : yabai -m window --resize bottom:0:-${vStepSize}  || yabai -m window --resize top:0:-${vStepSize}
 
      lctrl + rcmd - w : yabai -m window --resize top:0:-${vStepSize}  || yabai -m window --resize bottom:0:-${vStepSize}
      lctrl + rcmd - s : yabai -m window --resize top:0:${vStepSize}  || yabai -m window --resize bottom:0:${vStepSize}
      lctrl + rcmd - a : yabai -m window --resize left:-${vStepSize}:0  || yabai -m window --resize right:-${vStepSize}:0
      lctrl + rcmd - d : yabai -m window --resize left:${vStepSize}:0  || yabai -m window --resize right:${vStepSize}:0
 
      lctrl + rcmd - 0x2B : ${homeDir}/bin/darwin/,y_float.fish 1:2:0:0:1:1
      lctrl + rcmd - 0x2F : ${homeDir}/bin/darwin/,y_float.fish 1:2:1:0:1:1
      lctrl + rcmd - c : ${homeDir}/bin/darwin/,y_float.fish 4:4:1:1:2:2
      lctrl + rcmd + shift - c : ${homeDir}/bin/darwin/,y_float.fish 6:6:1:1:4:4
 
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
      lcmd - s  : pmset sleepnow
      rcmd + shift - s  : yabai -m window --display recent && yabai -m display --focus recent
 
      # rcmd - r  : yabai -m space --focus recent # not without scripting additions :-(
      rcmd + shift - t : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')
 
      rcmd + rctrl - c : ${homeDir}/bin/darwin/,y_focus.fish Calendar
      rcmd + rctrl - m : ${homeDir}/bin/darwin/,y_focus.fish Mail
      rcmd - b : ${homeDir}/bin/darwin/,y_focus.fish "Firefox"
      rcmd - 0x29 : ${homeDir}/bin/darwin/,y_focus.fish "qutebrowser"

      rcmd - m : ${homeDir}/bin/darwin/,y_focus.fish "Slack"
      rcmd - z : ${homeDir}/bin/darwin/,y_focus.fish "zoom.us"
      # TODO: slack + obsidian bindings!
      rcmd - g : ${homeDir}/bin/darwin/,y_overlay.fish Obsidian /Applications/Obsidian.app/Contents/MacOS/Obsidian global
      rcmd - o : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty overlay >> /tmp/tpx
      rcmd - t : ${homeDir}/bin/darwin/,y_tmux_term.fish ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty main >> /tmp/tpx

      # typing
      fn - t : ${pkgs.skhd}/bin/skhd -t "thomas.peiselt@coralogix.com"
    '';
  };
}
