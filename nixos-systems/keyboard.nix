{ ... }:
{
  services.kanata = {
    enable = true;
    keyboards.piantor.configFile = ../kanata/piantor_thinkpad.kbd;
  };
}
