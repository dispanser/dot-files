# NixOS module for llm-proxy — a small OpenAI-compatible proxy that fronts one
# or more LLM servers and runs shell hooks around requests (wake-on-LAN,
# keep-awake/caffeine, KV-cache slot saves, API-key injection).
#
# The generated config.toml mirrors the upstream file format one-to-one:
#
#   [server]
#   listen = "10.1.3.10:3333"
#
#   [backends.default]
#   url = "http://10.1.3.4:3333"
#   pre_request_hook = "scripts/start-backend.sh"
#   ...
#
# The program reads its config from $LLM_PROXY_CONFIG (default: ./config.toml)
# and resolves relative hook paths against the directory containing that file.
# Both are set up here: the config is materialised as a store directory holding
# `config.toml` plus the hook scripts under `scripts/`, and the service points
# $LLM_PROXY_CONFIG at it.
#
# Secrets: `backends.<name>.apiKey` may reference an environment variable, which
# systemd supplies through `environmentFile`. With sops-nix that looks like
#
#   sops.secrets.tabby_api_key = { };
#   sops.templates.llm_proxy_env.content =
#     "TABBY_API_KEY=''${config.sops.placeholder.tabby_api_key}";
#   services.llm-proxy.environmentFile = config.sops.templates.llm_proxy_env.path;
#
# and needs `sops.useSystemdActivation = true`, because /run/secrets is tmpfs:
# the default activation-script install would leave it empty after a reboot.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.llm-proxy;
  format = pkgs.formats.toml { };

  # A hook is either a script we can place next to the generated config — a
  # path, a derivation, or a string pointing into the Nix store such as
  # "''${pkg}/bin/foo" (derivation attributes are strings, so plain paths are
  # the exception) — or a plain string, written verbatim and resolved by the
  # program relative to the config directory. Store scripts are referenced by
  # file name under scripts/, which keeps the generated config.toml in the same
  # shape as a hand-written one.
  hookType = lib.types.either lib.types.str lib.types.path;
  isStoreScript =
    v:
    builtins.isPath v
    || lib.isDerivation v
    || (lib.isString v && lib.hasPrefix builtins.storeDir v);
  # The store reference is dropped on purpose: the copy in `configDir` carries
  # it, while the config file refers to the script by name only.
  hookRelName = v: builtins.unsafeDiscardStringContext "scripts/${baseNameOf (toString v)}";
  hookValue = v: if isStoreScript v then hookRelName v else v;

  backendModule = { ... }: {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        example = "http://10.1.3.4:3333";
        description = ''
          Base URL of the backend LLM server (llama-server, TabbyAPI, ...).
        '';
      };

      preRequestHook = lib.mkOption {
        type = lib.types.nullOr hookType;
        default = null;
        example = lib.literalExpression "\${cfg.hooksSource}/start-backend.sh";
        description = ''
          Script run before every forwarded request (e.g. to wake the backend
          via wake-on-LAN and wait for it). Store paths are copied into the
          generated config directory and referenced as {file}`scripts/<name>`;
          any other string is written verbatim and resolved relative to that
          directory.
        '';
      };

      hookTimeoutSecs = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        example = 60;
        description = ''
          Maximum time any hook is allowed to run, in seconds. The program
          default is 30.
        '';
      };

      keepAwakeEnableHook = lib.mkOption {
        type = lib.types.nullOr hookType;
        default = null;
        example = lib.literalExpression "\${cfg.hooksSource}/caffeine-enable.sh";
        description = ''
          Script run when traffic is seen after an idle gap, to keep the backend
          machine from suspending mid-response.
        '';
      };

      keepAwakeDisableHook = lib.mkOption {
        type = lib.types.nullOr hookType;
        default = null;
        example = lib.literalExpression "\${cfg.hooksSource}/caffeine-disable.sh";
        description = ''
          Script run once the backend has been idle for
          {option}`services.llm-proxy.backends.<name>.keepAwakeGraceSecs`,
          letting the backend machine suspend again. Also run on shutdown.
        '';
      };

      keepAwakeGraceSecs = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        example = 300;
        description = ''
          Grace period after the last request during which the backend is kept
          awake, in seconds. The program default is 300.
        '';
      };

      preloadSaveIdleSecs = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        example = 60;
        description = ''
          Idle delay before the active conversation's KV-cache slot is saved to
          disk, in seconds. The program default is 60. Keep it below
          {option}`keepAwakeGraceSecs` so the save happens before the backend
          suspends.
        '';
      };

      apiKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "$TABBY_API_KEY";
        description = ''
          Static API key sent to the backend as an
          {env}`Authorization: Bearer <key>` header, replacing whatever the
          client sent. When unset, the client's `Authorization` header is
          forwarded unchanged.

          The value may reference environment variables (`$VAR` / `''${VAR}`);
          `$$` is a literal `$`, and a reference to an unset variable makes the
          service fail at startup. Supply the value through
          {option}`services.llm-proxy.environmentFile` — anything written here
          ends up in the world-readable Nix store.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        example = { model_whitelist = [ "qwen" ]; };
        description = ''
          Extra keys for this backend's table, merged into the generated TOML.
          Escape hatch for upstream options this module does not model yet.
        '';
      };
    };
  };

  hookFields = [
    "preRequestHook"
    "keepAwakeEnableHook"
    "keepAwakeDisableHook"
  ];

  # Every hook that refers to a script we can copy, as
  # { rel = "scripts/<name>"; src = <store path>; what = "backends.<x>.<field>"; }.
  scriptHooks = lib.concatLists (
    lib.mapAttrsToList (
      bName: backend:
      lib.concatMap (
        field:
        let
          v = backend.${field};
        in
        if isStoreScript v then
          [
            {
              rel = hookRelName v;
              src = v;
              what = "backends.${bName}.${field}";
            }
          ]
        else
          [ ]
      ) hookFields
    ) cfg.backends
  );

  # Hooks given as store scripts are copied into the config directory by file
  # name, so two scripts with the same basename would overwrite each other.
  hookCollisions = lib.filterAttrs (_: g: builtins.length g > 1) (lib.groupBy (e: e.rel) scriptHooks);

  # `null` means "not set": the program has its own defaults, so those keys are
  # dropped instead of being written as empty TOML values.
  backendToTOML = backend:
    lib.recursiveUpdate (lib.filterAttrs (_: v: v != null) {
      url = backend.url;
      pre_request_hook = hookValue backend.preRequestHook;
      hook_timeout_secs = backend.hookTimeoutSecs;
      keep_awake_enable_hook = hookValue backend.keepAwakeEnableHook;
      keep_awake_disable_hook = hookValue backend.keepAwakeDisableHook;
      keep_awake_grace_secs = backend.keepAwakeGraceSecs;
      preload_save_idle_secs = backend.preloadSaveIdleSecs;
      api_key = backend.apiKey;
    }) backend.extraConfig;

  settings = lib.recursiveUpdate {
    server = {
      listen = cfg.listen;
    };
    backends = lib.mapAttrs (_: backendToTOML) cfg.backends;
  } cfg.extraConfig;

  configFile = format.generate "llm-proxy-config.toml" settings;

  # config.toml and its hook scripts must live in one directory: the program
  # canonicalises the config path and resolves relative hook paths against the
  # resulting parent directory, so a symlinked config file would drag
  # `scripts/...` off to its /nix/store parent.
  #
  # `${e.src}` relies on the hook carrying its store-path context (true for
  # anything derived from a package); a hand-typed literal store path would not
  # become a build dependency of this directory.
  configDir = pkgs.runCommand "llm-proxy" { } ''
    mkdir -p $out
    cp ${configFile} $out/config.toml
    ${lib.concatMapStringsSep "\n" (
      e: ''
        mkdir -p $out/${dirOf e.rel}
        cp ${e.src} $out/${e.rel}
        chmod +x $out/${e.rel}
      ''
    ) scriptHooks}
  '';

  serviceEnvironment = [
    "LLM_PROXY_CONFIG=${cfg.generatedConfigFile}/config.toml"
  ] ++ lib.mapAttrsToList (n: v: "${n}=${v}") cfg.environment;

in
{
  options.services.llm-proxy = {
    enable = lib.mkEnableOption "llm-proxy, an LLM proxy with pre/post-request hooks";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llm-proxy;
      defaultText = lib.literalExpression "pkgs.llm-proxy";
      description = ''
        The llm-proxy package to use. Packaged in
        {file}`nixos-systems/overlays/llm-proxy.nix`; its `src` doubles as the
        default {option}`hooksSource`.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "llm-proxy";
      description = ''
        Account the proxy runs as. The default is a dedicated system user
        created by this module; set it to an existing user (e.g. `pi`) to reuse
        that account's environment — note that the keep-awake scripts fall back
        to `ssh`, which then needs a key in that user's home.
      '';
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8090";
      example = "10.1.3.10:3333";
      description = ''
        Address and port the proxy listens on ({config}`[server].listen`).
      '';
    };

    backends = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule backendModule);
      default = { };
      example = lib.literalExpression ''
        {
          default = {
            url = "http://10.1.3.4:3333";
            preRequestHook = "''${config.services.llm-proxy.hooksSource}/start-backend.sh";
            hookTimeoutSecs = 60;
            keepAwakeEnableHook = "''${config.services.llm-proxy.hooksSource}/caffeine-enable.sh";
            keepAwakeDisableHook = "''${config.services.llm-proxy.hooksSource}/caffeine-disable.sh";
            keepAwakeGraceSecs = 300;
            preloadSaveIdleSecs = 60;
            apiKey = "$TABBY_API_KEY";
          };
        }
      '';
      description = ''
        Backends to proxy. The program currently only ever uses the backend
        named {var}`default`; other entries are written to the config for
        documentation and future use.
      '';
    };

    hooksSource = lib.mkOption {
      type = hookType;
      default = "${cfg.package.src}/scripts";
      defaultText = lib.literalExpression "\${pkgs.llm-proxy.src}/scripts";
      description = ''
        Directory holding the hook scripts to reference. Defaults to the `scripts/`
        directory shipped with the package — beware that those encode one particular
        host's backend address and MAC, so they are only referenced when you opt in
        via the per-backend hook options.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        RUST_LOG = "llm_proxy=debug,info";
        CAFFEINE_ADDR = "10.1.3.4";
      };
      description = ''
        Extra environment variables for the service. Values end up in the unit
        file, so use this for non-secrets only ({env}`RUST_LOG`, the
        {env}`CAFFEINE_*` transport overrides the hook scripts understand, ...)
        and {option}`environmentFile` for API keys.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = lib.literalExpression "config.sops.templates.llm_proxy_env.path";
      description = ''
        Path to a {file}`KEY=value` file passed to systemd
        {env}`EnvironmentFile`, for the secrets referenced by
        {option}`backends.<name>.apiKey`. systemd reads it as root before
        dropping privileges, so a `0500` sops secret works fine.

        A bare-key sops secret is not dotenv, so render it first:
        ```nix
        sops.secrets.tabby_api_key = { };
        sops.templates.llm_proxy_env.content =
          "TABBY_API_KEY=''${config.sops.placeholder.tabby_api_key}";
        services.llm-proxy.environmentFile =
          config.sops.templates.llm_proxy_env.path;
        ```
        Do not put the secret in {option}`environment` instead: unit files are
        world-readable in the Nix store, and so is the generated config.toml.
      '';
    };

    hookPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.bash
        pkgs.coreutils
        pkgs.curl
        pkgs.perl
        pkgs.openssh
      ];
      defaultText = lib.literalExpression "[ pkgs.bash pkgs.coreutils pkgs.curl pkgs.perl pkgs.openssh ]";
      description = ''
        Packages on the service {env}`PATH`, so hook scripts find their tools.
        The proxy spawns hooks directly rather than through a login shell. The
        scripts shipped with llm-proxy call `bash`, `curl`, `perl` (the
        wake-on-LAN magic packet), `sleep`/`seq` (coreutils) and, with
        `CAFFEINE_TRANSPORT=ssh`, `ssh`.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = {
        server = {
          some_future_key = 1;
        };
      };
      description = ''
        Extra top-level TOML, merged recursively into the generated config.
        Escape hatch for upstream options this module does not model yet.
      '';
    };

    generatedConfigFile = lib.mkOption {
      type = lib.types.path;
      internal = true;
      description = ''
        Store directory holding the generated config.toml and its hook scripts.
        Exposed so it can be used as a `restartTriggers` input.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.backends ? default;
        message = ''
          services.llm-proxy.backends.default is required: llm-proxy refuses to
          start without a backend named "default".
        '';
      }
      {
        assertion = hookCollisions == { };
        message =
          let
            clashes = lib.concatStringsSep "\n  " (
              lib.flatten (
                lib.mapAttrsToList (
                  rel: g: map (e: "${rel} <- services.llm-proxy.${e.what}") g
                ) hookCollisions
              )
            );
          in
          ''
            services.llm-proxy: hook scripts are copied into the generated config
            directory under scripts/ by file name, so these names collide:
              ${clashes}
            Rename one script, or pass a string to reference it by path instead.
          '';
      }
    ];

    services.llm-proxy.generatedConfigFile = configDir;

    environment.systemPackages = [ cfg.package ];

    users.groups.llm-proxy = lib.mkIf (cfg.user == "llm-proxy") { };
    users.users.llm-proxy = lib.mkIf (cfg.user == "llm-proxy") {
      isSystemUser = true;
      group = "llm-proxy";
    };

    systemd.services.llm-proxy = {
      description = "llm-proxy: LLM proxy with pre/post-request hooks";
      after = [
        "network-online.target"
        "sops-install-secrets.service"
      ];
      wants = [ "network-online.target" ];
      # The proxy spawns hook scripts directly, so they inherit this service's
      # environment: `#!/usr/bin/env bash` needs bash on $PATH, and the shipped
      # scripts call curl, perl and ssh (see hookPackages). NixOS merges this
      # into the unit PATH alongside its own defaults.
      # (The `noctalia` calls in the caffeine hooks run on the *backend*, inside
      # the quoted remote command, so they need nothing here.)
      path = cfg.hookPackages ++ [ cfg.package ];
      # Restart when the generated config (or its hooks) changes.
      restartTriggers = [ cfg.generatedConfigFile ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        User = cfg.user;
        Group = cfg.user;
        Environment = serviceEnvironment;
        Restart = "on-failure";
        RestartSec = 5;
        # The proxy handles SIGTERM by running the keep-awake disable hook and
        # stopping its idle checker, so let it finish before SIGKILL.
        KillSignal = "SIGTERM";
        TimeoutStopSec = 30;
        NoNewPrivileges = true;
        PrivateTmp = true;
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}