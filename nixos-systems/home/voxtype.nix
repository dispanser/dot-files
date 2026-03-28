{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.voxtype;
  tomlType = pkgs.formats.toml { };

  # Generate config from settings (arbitrary attribute set -> TOML)
  generatedConfig = tomlType.generate "voxtype-config" cfg.settings;

  # Determine config file path: xdg.configFile > configFile option > generated config
  configPath =
    let
      xdgConfig = config.xdg.configFile."voxtype/config.toml" or { source = null; };
    in
    if xdgConfig.source != null then xdgConfig.source else (
      if cfg.configFile != null then cfg.configFile else generatedConfig
    );
in
{
  meta.maintainers = [ ];

  options.programs.voxtype = {
    enable = lib.mkEnableOption "voxtype voice-to-text daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.voxtype;
      defaultText = lib.literalExpression "pkgs.voxtype";
      description = "voxtype package to use";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to an external TOML configuration file";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype voice-to-text daemon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
