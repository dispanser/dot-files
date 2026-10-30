#!/usr/bin/env fish
# Focus an app's first window, or cycle when one of its windows has focus.
# Usage: ,y_focus.fish [--regex] APP
# APP is an exact name by default; --regex enables jq's regular expressions.

argparse --min-args=1 --max-args=1 regex -- $argv
or exit 2

set -l regex false
if set -q _flag_regex
    set regex true
end

set -l windows (yabai -m query --windows)
or exit $status

set -l matches (printf '%s\n' "$windows" | jq --arg matcher "$argv[1]" --argjson regex $regex '
    map(select(if $regex then (.app | test($matcher)) else .app == $matcher end))
')
or exit $status

set -l ids (printf '%s\n' "$matches" | jq -r '.[].id')
if test (count $ids) -eq 0
    exit 0
end

set -l focused_id (printf '%s\n' "$matches" | jq -r '.[] | select(."has-focus" == true) | .id')
set -l target_id $ids[1]

if test -n "$focused_id"
    set -l index (contains -i -- $focused_id $ids)
    set -l next_index (math "$index % $(count $ids) + 1")
    set target_id $ids[$next_index]
end

yabai -m window --focus $target_id
