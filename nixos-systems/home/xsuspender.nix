{ pkgs, ... }:
{
  services.xsuspender = {
    enable = false;
    debug = true;
    defaults = {
      suspendDelay = 60;
      resumeEvery = 120; # default = 50
      resumeFor = 5; # default
      onlyOnBattery = true;
    };
    # see https://github.com/kernc/xsuspender/blob/master/data/xsuspender.conf
    rules = { 
      chromium = {
        matchWmClassContains  = "chromium-browser";
        suspendDelay          = 20;
        suspendSubtreePattern = "chromium";
        onlyOnBattery = true;
      };
      signal = {
        matchWmClassContains = "Signal.*";
        suspendSubtreePattern = ".*"; 
        # execSuspend = ''${pkgs.bash}/bin/bash -c echo "suspending window $XID of process $PID"'';
      };
      telegram = {
        matchWmClassContains = "telegram-desktop";
        suspendSubtreePattern = ".*"; 
      };
      qute = {
        matchWmClassGroupContains = "qutebrowser";
        suspendDelay              = 300;
        suspendSubtreePattern     = ".*";
      };
      firefox = {
        matchWmClassContains  = "Navigator";
        suspendDelay          = 20;
        suspendSubtreePattern = "\/(firefox|plugin-container)";
        
      };
    };
  };
}
