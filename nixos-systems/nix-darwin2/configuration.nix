{ config, pkgs, lib, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # tpx013
  environment.systemPackages = with pkgs;
    [ 
      neovim
      alacritty
      tmux
      openssh
    ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "@admin"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  nix.configureBuildUsers = true;
  services.nix-daemon.enable = true;

  # Enable experimental nix command and flakes

  homebrew = {
    enable = true;
    casks = [
      "qutebrowser"
    ];
    brews = [
      "openssh"
    ];
  };
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/src/github/dispanser/dot-files/nixos-systems/nix-darwin2/configuration.nix
  environment.darwinConfig = "$HOME/src/github/dispanser/dot-files/nixos-systems/nix-darwin2/configuration.nix";
  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCommandAndLeftAlt = true;
    remapCapsLockToEscape = true;
    # TODO: does not work for the ThinkPad Keyboard II - no tilde at all
    nonUS.remapTilde = false;
  };

  # Auto upgrade nix package and the daemon service.

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  services.yabai = {
    enable = true;
    config = {
      focus_follows_mouse = "autoraise";
      mouse_follows_focus = "on";
      window_placement    = "second_child";
      window_opacity      = "off";
      layout              = "bsp";
      top_padding         = 10;
      bottom_padding      = 10;
      left_padding        = 10;
      right_padding       = 10;
      window_gap          = 10;
    };

  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      rcmd - x : yabai -m window --focus recent
      rcmd - h : yabai -m window --focus west
      rcmd - j : yabai -m window --focus south
      rcmd - k : yabai -m window --focus north
      rcmd - l : yabai -m window --focus east
      rcmd - 0x2B : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
      rcmd - 0x2F : yabai -m window --focus stack.next || yabai -m window --focus stack.first

      rcmd - t : yabai -m window --toggle float --grid 4:4:1:1:2:2
      rcmd - o : yabai -m window --toggle topmost
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
      lctrl + rcmd - l : yabai -m window --resize right:50:0  || yabai -m window --resize left:50:0
      lctrl + rcmd - h : yabai -m window --resize right:-50:0  || yabai -m window --resize left:-50:0
      lctrl + rcmd - j : yabai -m window --resize bottom:0:100  || yabai -m window --resize top:0:100
      lctrl + rcmd - k : yabai -m window --resize bottom:0:-100  || yabai -m window --resize top:0:-100

      rcmd - f : yabai -m window --toggle zoom-fullscreen
      rcmd + shift - f : yabai -m window --toggle zoom-parent

      # switch display monitor
      rcmd - s  : yabai -m display --focus recent
      rcmd + shift - r  : yabai -m window --space recent
      rcmd + shift - 1  : yabai -m window --space 1
      rcmd + shift - 2  : yabai -m window --space 2
      rcmd + shift - 3  : yabai -m window --space 3
      rcmd + shift - 4  : yabai -m window --space 4
      rcmd + shift - 5  : yabai -m window --space 5
      rcmd + shift - 6  : yabai -m window --space 6

      # send window to monitor and follow focus
      rcmd + shift - s  : yabai -m window --display recent && yabai -m display --focus recent

      # rcmd - r  : yabai -m space --focus recent # not without scripting additions :-(
      rcmd + shift - t : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')


      # application-specific magic
      rcmd + rctrl - s : ,y_focus.fish Slack
      rcmd + rctrl - c : ,y_focus.fish Calendar
      rcmd + rctrl - m : ,y_focus.fish Mail
      rcmd + rctrl - b : ,y_focus.fish Safari
    '';
  };
}
