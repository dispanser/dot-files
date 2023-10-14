
{ pkgs, ... }:

# NOTICE THE USERNAME: otherwise, registering for root
# running as non-root doesn't work either (separate problem)
# sudo fprintd-enroll -f right-index-finger pi
# sudo fprintd-enroll -f right-index-finger pi
# sudo fprintd-enroll -f left-index-finger pi
# sudo fprintd-enroll -f right-thumb pi
{
  services.fprintd.enable = true;

  # probably not necessary - the default value is that of config.services.fprintd.enable
  security.pam.services = {
    login.fprintAuth        = true;
    xscreensaver.fprintAuth = true;
    xlock.fprintAuth        = true;
    sudo.fprintAuth         = true;
  };
}
