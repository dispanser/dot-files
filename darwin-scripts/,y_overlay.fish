#!/usr/bin/env fish
#
# arguments: 
# 1. app identifier
# 2. command to run if not found
# 3. 'global' vs 'local': per-space or one global window
#
# TODO: consider the floating status:
# - windows is floating: hide
# - windows is managed, and space is not floating: switch to recent?
#   - see below for an alternative strategy to `recent`
#
# TODO: don't switch to another space if the most recent window is elsewhere
# - focus another window from the current space 
#   - but we don't know which one is more recent
#   - what about `stack-index` from window info?
# - if it's the only window, 

# TODO: try to identify windows based on their title 
#   - seems to work for tmux inside alacritty
#

if [ $argv[3] = 'local' ];
	echo space-local operations
	set per_space '--space'
else
	set  per_space ''
end

echo args: $per_space

set -l id (yabai -m query --windows $per_space | jq ".[] | select (.app | test(\"$argv[1]\")) | .id")

if [ -z $id ];
	echo no id: starting $argv[2]
	$argv[2]
else
	echo with id: $id

	set current_id (yabai -m query --windows --window | jq .id)

	echo $id '<>' $current_id

	if [ $id = $current_id ];
		echo window is currently active, minimize
		yabai -m window --minimize $id --focus recent
	else
		set space (yabai -m query --spaces --space | jq '.index')
		echo bring to space $space and focus
		yabai -m window $id --space $space --focus $id --deminimize $id
	end
end
