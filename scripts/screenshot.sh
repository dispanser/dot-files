#!/usr/bin/env sh

f=$(mktemp -u /home/data/tmp/screenshots/`date +%F_%H-%M-%S`_XXXXXX.png)
scrot -s $f
readlink -f $f | tr -d '\n' | xclip -in -selection clipboard

echo $f
