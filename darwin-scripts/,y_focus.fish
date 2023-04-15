#!/usr/bin/env fish

echo focus.fish: query for \"$argv[1]\"  >> /tmp/tpx

yabai -m window --focus (yabai -m query --windows | jq ".[] | select (.app == \"$argv[1]\") | .id")
