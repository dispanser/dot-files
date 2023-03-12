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
      alt - x : yabai -m window --focus recent
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east
      alt - z : yabai -m window --focus stack.prev
      alt - c : yabai -m window --focus stack.next

      # swap window
      shift + alt - x : yabai -m window --swap recent
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east
    '';
  };
}
