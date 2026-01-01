#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace

GHOSTTY_ID='com.mitchellh.ghostty'
GHOSTTY_WORKSPACE='5'
EVICT_WORKSPACE='6'

mode="${1:-}"

evict_non_ghostty_from_workspace_5() {
    "$AEROSPACE" list-windows --workspace "$GHOSTTY_WORKSPACE" --format '%{window-id}%{tab}%{app-bundle-id}' |
        awk -F'\t' -v ghost="$GHOSTTY_ID" '$2 != ghost { print $1 }' |
        while IFS= read -r other_id; do
            [[ -n "$other_id" ]] || continue
            "$AEROSPACE" move-node-to-workspace --window-id "$other_id" "$EVICT_WORKSPACE"
        done
}

move_all_ghostty_to_workspace_5() {
    "$AEROSPACE" list-windows --monitor all --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}' |
        while IFS= read -r ghostty_window_id; do
            [[ -n "$ghostty_window_id" ]] || continue
            "$AEROSPACE" move-node-to-workspace --window-id "$ghostty_window_id" "$GHOSTTY_WORKSPACE"
        done
}

case "$mode" in
    sweep)
        evict_non_ghostty_from_workspace_5
        move_all_ghostty_to_workspace_5
        exit 0
        ;;
    ghostty-window)
        window_id="${AEROSPACE_WINDOW_ID:-}"
        [[ -n "$window_id" ]] || exit 0

        evict_non_ghostty_from_workspace_5
        move_all_ghostty_to_workspace_5
        "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$GHOSTTY_WORKSPACE"
        "$AEROSPACE" workspace "$GHOSTTY_WORKSPACE" || true
        exit 0
        ;;
    evict-window)
        window_id="${AEROSPACE_WINDOW_ID:-}"
        [[ -n "$window_id" ]] || exit 0
        "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$EVICT_WORKSPACE"
        "$AEROSPACE" workspace "$EVICT_WORKSPACE" || true
        exit 0
        ;;
    *)
        echo "Usage: $(basename "$0") {ghostty-window|evict-window|sweep}" >&2
        exit 2
        ;;
esac
