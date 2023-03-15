#!/usr/bin/env fish

set -l id (yabai -m query --windows --space | jq ".[] | select (.app | test(\"$argv[1]\")) | .id")
test -z $id && $argv[2] || yabai -m window --focus $id
