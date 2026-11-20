{ pkgs, ... }:

{
  ids.gids.nixbld = 350;
  nixpkgs.config.allowUnfree = true;
  nix.enable = true;
  users.users."thomas.peiselt" = {
    home = "/Users/thomas.peiselt";
    name = "thomas.peiselt";
    shell = pkgs.fish;
    uid = 502;
  };

  imports = [
    ./kanata.nix
    ./omniwm.nix
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
      "postman"
      "signal"
      "zerotier-one"
      "stats"
      "teleport-suite"
      "orbstack"
    ];
    brews = [
      "awscli"
      "golang"
      "openssh"
      "sandgardenhq/tap/mdfetch"
      "nace-ai/tap/kapitsa"
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
    remapCapsLockToEscape = true;
    swapLeftCommandAndLeftAlt = true;
    swapRightCommandAndRightOption = true;
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

  security.sudo.extraConfig = ''
    thomas.peiselt ALL=(root) NOPASSWD: /etc/profiles/per-user/thomas.peiselt/bin/openvpn *
  '';

  # services.karabiner-elements.enable = true;

  # Kapitsa: local inference server on 127.0.0.1:8000, model pinned in
  # ~/.cache/kapitsa/serve.json. User agent so it sees ~/.cache/kapitsa.
  launchd.user.agents.kapitsa = {
    command = "/opt/homebrew/bin/kapitsa serve";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/kapitsa.log";
      StandardErrorPath = "/tmp/kapitsa-error.log";
    };
  };

  launchd.daemons.unison = {
    script = ''
      ${pkgs.unison}/bin/unison \
        -root /Users/thomas.peiselt/projects/coralogix/ \
        -root ssh://tiny//home/data/sync/home/pi/projects/coralogix/ \
        -repeat watch -auto -batch \
        -ignore="Name target" -ignore="Name .tp/targets" -ignore="Name build" -ignore="Name perf.data*" -ignore="Name debug" \
        -ignore="Name *.o" \
        -ignore="Name *.hi" \
        -ignore="Name *.class" \
        -ignore="Name *.jar" \
        -ignore="Name .qute/cache" \
        -ignore="Name .qute/data" \
        -ignore="Name .qute/runtime" \
        -ignore="Name *.log" \
        -ignore="Name .direnv" \
        -ignore="Name .devenv*" \
        -ignore="Name __pycache__" \
        -path=src \
        -path=wip \
        -path=notes
    '';
    environment = {
    };
    path = with pkgs; [
      openssh
      unison-fsmonitor
    ];
    serviceConfig = {
      Disabled = false;
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/unison.log";
      StandardErrorPath = "/tmp/unison-error.log";
      UserName = "thomas.peiselt";
    };
  };

}
