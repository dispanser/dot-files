{ ... }:
{
  services.kanata = {
    enable = true;
    keyboards.piantor = {
      configFile = ../kanata/piantor_thinkpad.kbd;
      extraArgs = [ "--wait-device-ms" "3000" ];
    };
  };
}
