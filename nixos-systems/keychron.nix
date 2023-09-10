{ pkgs, ... }:
{
  # services.udev.extraRules = ''KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="pi", TAG+="uaccess", TAG+="udev-acl"'';
  services.udev = {
    packages = with pkgs; [ via ];

    extraRules = ''KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", ATTRS{idVendor}=="3434", GROUP="pi", TAG+="uaccess", TAG+="udev-acl"'';
  };
}
