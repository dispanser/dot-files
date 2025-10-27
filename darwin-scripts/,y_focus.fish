#!/usr/bin/env fish
# filepath: darwin-scripts/,y_focus.fish

# 1️⃣ Get a space‑separated list of all window IDs whose app matches the argument
set -l ids (yabai -m query --windows \
    | jq -r ".[] | select(.app == \"$argv[1]\") | .id")

# Exit if nothing matches
if test -z "$ids"
    exit 0
end

# 2️⃣ Find the ID of the currently focused window among those matches
set -l focused_id (yabai -m query --windows \
    | jq -r ".[] | select(.app == \"$argv[1]\" and .\"has-focus\" == true) | .id")

set -l id_array $ids
set -l target_id ""

# 3️⃣ Determine which ID to focus
if test -n "$focused_id"
    # Locate the index of the focused window inside the array
    set -l idx 0
    for i in (seq (count $id_array))
        if test $id_array[$i] = $focused_id
            set idx $i
            break
        end
    end

    # Compute the next index, wrapping around to the first element if needed
    set -l total (count $id_array)
    set -l next_idx (math "$idx % $total + 1")
    set target_id $id_array[$next_idx]
else
    # No matching window currently has focus – fall back to the original behaviour
    set target_id $id_array[1]
end

# 4️⃣ Focus the chosen window
yabai -m window --focus $target_id
