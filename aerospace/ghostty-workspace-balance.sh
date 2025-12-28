#!/usr/bin/env bash
# Distribute Ghostty windows: max 3 per workspace
# Workspaces: 1 → 5 → 6 → 7 → ...
# Called by on-window-detected with AEROSPACE_WINDOW_ID env var

set -e

GHOSTTY_ID="com.mitchellh.ghostty"
WORKSPACES=(1 5 6 7 8 9)  # Add more if needed
MAX_PER_WS=3

for ws in "${WORKSPACES[@]}"; do
    count=$(aerospace list-windows --workspace "$ws" --app-bundle-id "$GHOSTTY_ID" --count 2>/dev/null || echo 0)
    if [[ "$count" -lt "$MAX_PER_WS" ]]; then
        aerospace move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" "$ws"
        exit 0
    fi
done

# Fallback: all workspaces full, use last workspace anyway
aerospace move-node-to-workspace --window-id "$AEROSPACE_WINDOW_ID" "${WORKSPACES[-1]}"
