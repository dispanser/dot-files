#!/usr/bin/env fish
# Focus an application's first window, or cycle when it already has focus.
# Usage: focus-app.fish BUNDLE_ID
# Window IDs define a stable cycle across layout and workspace changes.

argparse --min-args=1 --max-args=1 -- $argv
or exit 2

set -l bundle_id $argv[1]
set -l windows (omniwmctl query windows --bundle-id "$bundle_id" --format json)
or exit $status

set -l target (printf '%s\n' "$windows" | jq -r --arg bundle "$bundle_id" '
    if .ok != true or (.result.payload.windows | type) != "array" then
        error("Invalid OmniWM window response")
    else
        .result.payload.windows
    end
    | map(select(.app.bundleId == $bundle and .hiddenReason != "scratchpad"))
    | sort_by(.windowId)
    | (map(.isFocused == true) | index(true)) as $focused
    | if length == 0 then empty
      elif $focused == null then .[0].id
      else .[($focused + 1) % length].id
      end
    | if type == "string" and length > 0 then .
      else error("Invalid OmniWM window ID")
      end
')
or exit $status

if test -n "$target"
    omniwm-terminal focus-app --window "$target"
else
    omniwm-terminal focus-app --bundle-id "$bundle_id"
end
