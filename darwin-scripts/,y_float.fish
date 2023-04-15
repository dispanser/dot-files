#!/usr/bin/env fish

set floating (yabai -m query --windows --window | jq -e '."is-floating"')

if [ $floating = "true" ];
	echo "is floating, relocating"
	yabai -m window --grid $argv[1]
else
	echo "is managed, floating and relocating"
	yabai -m window --toggle float --grid $argv[1]
end
