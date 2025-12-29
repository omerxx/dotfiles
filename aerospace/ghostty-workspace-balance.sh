#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace
GHOSTTY_ID="com.mitchellh.ghostty"
WORKSPACES=(1 5 6 7 8 9)
MAX_PER_WS=3

$AEROSPACE move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" 0

for ws in "${WORKSPACES[@]}"; do
    count=$($AEROSPACE list-windows --workspace "$ws" --app-bundle-id "$GHOSTTY_ID" --count 2>/dev/null || echo 0)
    if [[ "$count" -lt "$MAX_PER_WS" ]]; then
        $AEROSPACE move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" --focus-follows-window "$ws"
        $AEROSPACE workspace "$ws"
        exit 0
    fi
done

$AEROSPACE move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" --focus-follows-window "${WORKSPACES[-1]}"
$AEROSPACE workspace "${WORKSPACES[-1]}"
