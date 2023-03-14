#!/usr/bin/env fish

yabai -m window --focus (yabai -m query --windows | jq ".[] | select (.app == \"$argv[1]\") | .id")
