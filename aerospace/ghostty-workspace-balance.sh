#!/usr/bin/env bash
set -e

GHOSTTY_ID="com.mitchellh.ghostty"
WORKSPACES=(1 5 6 7 8 9)
MAX_PER_WS=3

aerospace move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" __ghostty_hold__

for ws in "${WORKSPACES[@]}"; do
    count=$(aerospace list-windows --workspace "$ws" --app-bundle-id "$GHOSTTY_ID" --count 2>/dev/null || echo 0)
    if [[ "$count" -lt "$MAX_PER_WS" ]]; then
        aerospace move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" "$ws"
        exit 0
    fi
done

aerospace move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" "${WORKSPACES[-1]}"
