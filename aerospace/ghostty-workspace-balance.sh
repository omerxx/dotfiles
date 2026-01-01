#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace

GHOSTTY_ID='com.mitchellh.ghostty'
GHOSTTY_WORKSPACE='5'
EVICT_WORKSPACE='6'

window_id="${AEROSPACE_WINDOW_ID:-}"
if [[ -z "$window_id" ]]; then
    exit 0
fi

window_info="$(
    "$AEROSPACE" list-windows --all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}' |
        awk -F'\t' -v id="$window_id" '$1 == id { print $0; exit }'
)"

if [[ -z "$window_info" ]]; then
    exit 0
fi

app_id="$(awk -F'\t' '{ print $2 }' <<<"$window_info")"
workspace="$(awk -F'\t' '{ print $3 }' <<<"$window_info")"

if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
    "$AEROSPACE" list-windows --workspace "$GHOSTTY_WORKSPACE" --format '%{window-id}%{tab}%{app-bundle-id}' |
        awk -F'\t' -v ghost="$GHOSTTY_ID" '$2 != ghost { print $1 }' |
        while IFS= read -r other_id; do
            [[ -n "$other_id" ]] || continue
            "$AEROSPACE" move-node-to-workspace --window-id "$other_id" "$EVICT_WORKSPACE"
        done

    "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$GHOSTTY_WORKSPACE"
    "$AEROSPACE" workspace "$GHOSTTY_WORKSPACE"
    exit 0
fi

if [[ "$workspace" == "$GHOSTTY_WORKSPACE" ]]; then
    "$AEROSPACE" move-node-to-workspace --window-id "$window_id" "$EVICT_WORKSPACE"
fi
