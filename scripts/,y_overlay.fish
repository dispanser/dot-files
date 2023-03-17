#!/usr/bin/env fish
#
# arguments: 
# 1. app identifier
# 2. command to run if not found

set -l id (yabai -m query --windows | jq ".[] | select (.app | test(\"$argv[1]\")) | .id")

if [ -z $id ];
	echo no id: starting obsidian
	$argv[2]
else
	echo with id: $id

	set current_id (yabai -m query --windows --window | jq .id)

	echo $id '<>' $current_id

	if [ $id = $current_id ];
		echo window is currently active, minimize
		yabai -m window --minimize $id --focus recent
	else
		echo bring to space and focus
		set space (yabai -m query --spaces --space | jq '.id')
		yabai -m window $id --space $space --focus $id --deminimize $id
	end
end


# test -z $id && $argv[2] || yabai -m window --focus $id
