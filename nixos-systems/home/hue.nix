{ config, pkgs, ... }:

let
  myJsonData = {
    user = "cat ${config.sops.secrets.hue_api_key.path}";
    host = "192.168.1.32";
  };
in
{
  sops = {
    secrets.hue_api_key = { };
  };
  home.file.".hueadm.json" = {
    text = ''
      ${pkgs.lib.strings.toJSON myJsonData}
    '';
  };
}
