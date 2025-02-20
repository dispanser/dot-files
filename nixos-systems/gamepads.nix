{ ... }:
{
  services.udev = {
    enable = true; # explicit, even though that's the default
    extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
  };
}
