#!/usr/bin/env bash

xrandr > xrandr.state

cmd=$1
export CONNECTED=$(xrandr | rg ' connected' | cut -f 1 -d' ')
export DISCONNECTED=$(xrandr | rg 'disconnected( primary)? \d{4}x\d{4}' | cut -f 1 -d' ')

echo c: $CONNECTED
echo d: $DISCONNECTED

EXT=()
for output in $CONNECTED; do
	echo handling output $output
	if [[ "$output" =~ "eDP" ]]; then
		echo detected internal: $output
		INT=$output
	else
		echo detected external: $output
		EXT+=($output)
	fi
done;


echo "internal: $INT"
echo "external: $EXT"

# disconnect leftovers from previous changes
for output in $DISCONNECTED; do
	xrandr --output $output --off
done

function undock() {
	OFFS=""
	for output in $EXT; do
		OFFS+=" --output $output --off"
	done
	xrandr --output $INT --auto $OFFS
}

function dock() {
	case ${#EXT[@]} in
		"1")
			xrandr --output ${EXT[0]} --auto --right-of $INT --output $INT --auto
			;;
		"2")
			xrandr --output ${EXT[0]} --auto --output ${EXT[1]} --auto --right-of ${EXT[0]} --output $INT --off
			;;
		"0")
			echo "zero, nada"
			;;
	esac

}

function home() {
	xrandr --output ${EXT[0]} --auto --right-of $INT --output $INT --auto
}

function ext() {
	xrandr --output ${EXT[0]}  --auto --output $INT --off
}

case "$cmd" in  
	"dock")
		dock
		;;
	"undock")
		undock
		;;
	"home")
		home
		;;
	"ext")
		ext
		;;
	*)
		echo "unsupported command $cmd. It's [dock, undock, home, ext]!"
		;;
esac

