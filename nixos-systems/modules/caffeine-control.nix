# NixOS module for `caffeine-control` — the HTTP endpoint the llm-proxy
# keep-awake hooks hit to toggle noctalia's idle inhibitor on this machine.
#
#   GET /caffeine/enable   ->  noctalia msg caffeine-enable
#   GET /caffeine/disable  ->  noctalia msg caffeine-disable
#
# `noctalia msg` talks to the desktop shell over
# $XDG_RUNTIME_DIR/noctalia-$WAYLAND_DISPLAY.sock, so this cannot run as a
# system service: it has to be a *user* service inside the graphical session,
# which is where that socket (and the variables pointing at it) live. The
# session imports WAYLAND_DISPLAY/XDG_RUNTIME_DIR into the user manager, so a
# unit ordered after `graphical-session.target` sees them — same arrangement as
# the `programs.noctalia` user service.
#
# The service listens on all interfaces by default, because the proxy reaches
# it over the network (tiny curls http://10.1.3.4:8765, kite's zerotier
# address). Anyone who can route to the port can then toggle caffeine; bind to
# a specific address, firewall the port, or set a bearer token to restrict it.
# The token is read from $CAFFEINE_TOKEN — keep it out of `environment` (unit
# files are world-readable) and use an EnvironmentFile instead:
#
#   sops.secrets.caffeine_token = { };
#   systemd.user.services.caffeine-control.serviceConfig.EnvironmentFile =
#     config.sops.secrets.caffeine_token.path;
#
# and have the hooks send `Authorization: Bearer <token>`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.caffeine-control;

  # The script is stdlib-only, so it ships as a file in this repo instead of as
  # a packaged upstream program (cf. ./overlays/llm-proxy.nix).
  defaultPackage = pkgs.writers.writePython3Bin "caffeine-control" { } (builtins.readFile ./caffeine-control.py);
in
{
  options.services.caffeine-control = {
    enable = lib.mkEnableOption ''
      caffeine-control, an HTTP endpoint that toggles noctalia caffeine, run
      as a user service inside the graphical session
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "pkgs.writers.writePython3Bin … ./caffeine-control.py";
      description = ''
        The `caffeine-control` package to use, built from
        {file}`nixos-systems/modules/caffeine-control.py`.
      '';
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      example = "10.1.3.4";
      description = ''
        Address to bind ({env}`CAFFEINE_ADDR`). The default accepts requests
        from the proxy on any interface; narrow it to the address the proxy
        connects to if you would rather not answer on the LAN.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8765;
      description = ''
        Port to listen on ({env}`CAFFEINE_PORT`). The llm-proxy caffeine hooks
        default to the same port, override {env}`CAFFEINE_PORT` there too if
        you change it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.noctalia.enable;
        message = ''
          services.caffeine-control needs programs.noctalia: `noctalia msg` is
          a client of the desktop shell, which has to be running for caffeine
          to be toggled at all.
        '';
      }
    ];

    systemd.user.services.caffeine-control = {
      description = "caffeine-control: HTTP endpoint toggling noctalia caffeine";
      documentation = [ "https://github.com/dispanser/llm-proxy" ];
      # Start with the session (the user manager has WAYLAND_DISPLAY by then)
      # and stop when it goes away.
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      # NixOS' default service PATH has no `noctalia` on it, and the script
      # execs it by name.
      path = [ config.programs.noctalia.package ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Environment = [
          "CAFFEINE_ADDR=${cfg.listenAddress}"
          "CAFFEINE_PORT=${toString cfg.port}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}