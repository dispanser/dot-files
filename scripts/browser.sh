#! /usr/bin/env nix-shell
#! nix-shell -i fish -p fish wmctrl

# ACTIVE=$(wmctrl -d | grep -v  '  - DG:')
set ACTIVE (wmctrl -d | grep '\*' | cut -b 33- | cut -f 1 -d_)

qutebrowser --qt-arg name $ACTIVE --basedir  /home/pi/projects/$ACTIVE/.qute $argv
# firefox -P $ACTIVE --class firefox_$ACTIVE --profile /home/pi/projects/$ACTIVE/.firefox --new-tab $argv
