#!/usr/bin/env fish
# arguments
# 1. full path to terminal binary (must be alacritty for now)
# 2. a terminal tag or type: 

# query label of current space
set -l label (yabai -m query --spaces --space | jq --raw-output .label)

# build the name of the session / title. 
# used both inside tmux and as term title for finding it back
set session "$label/$argv[2]"

echo tmux session and title: $session

yabai -m query --windows --space | jq ".[] | select (.title | test(\"$session\")) | .id" | echo

set -l id (yabai -m query --windows --space | jq ".[] | select (.title | test(\"$session\")) | .id")

if [ -z $id ];
	echo no id: starting $argv[1]
	$argv[1] --title $session --command sh -c "tmux attach -t $session || tmux new-session -s $session"
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
