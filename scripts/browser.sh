#! /usr/bin/env nix-shell
#! nix-shell -i fish -p fish wmctrl

# PROJECT=$(wmctrl -d | grep -v  '  - DG:')
set PROJECT (wmctrl -d | string match -gr '\* DG.*WA: N\/A  ([^_]+)')

qutebrowser --qt-arg name $PROJECT --basedir  /home/pi/projects/$PROJECT/.qute $argv
# firefox -P $PROJECT --class firefox_$PROJECT --profile /home/pi/projects/$PROJECT/.firefox --new-tab $argv
