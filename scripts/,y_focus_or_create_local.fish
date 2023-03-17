#!/usr/bin/env fish
#
# arguments: 
# 1. app identifier
# 2. command to run if not found

set -l id (yabai -m query --windows --space | jq ".[] | select (.app | test(\"$argv[1]\")) | .id")
test -z $id && $argv[2] || yabai -m window --focus $id
