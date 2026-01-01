#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace

MAX_PER_WS=3

GHOSTTY_ID='com.mitchellh.ghostty'
GHOSTTY_PRIMARY_WS='1'
GHOSTTY_OVERFLOW_WS='5'
NON_GHOSTTY_OVERFLOW_WS='6'

OVERFLOW_WORKSPACES=(6 7 8 9)
NON_GHOSTTY_OVERFLOW_WORKSPACES=(6 7 8 9)

mode="${1:-on-window-detected}"

trigger_sketchybar_workspace_update() {
    if command -v sketchybar >/dev/null 2>&1; then
        sketchybar --trigger aerospace_workspace_change >/dev/null 2>&1 || true
    fi
}

get_window_info() {
    local window_id="$1"
    "$AEROSPACE" list-windows --monitor all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}' 2>/dev/null |
        awk -F'\t' -v id="$window_id" '$1 == id { print $0; exit }'
}

count_windows_in_ws() {
    local ws="$1"
    "$AEROSPACE" list-windows --workspace "$ws" --count 2>/dev/null || echo 0
}

count_app_windows_in_ws() {
    local ws="$1"
    local app_id="$2"
    "$AEROSPACE" list-windows --workspace "$ws" --app-bundle-id "$app_id" --count 2>/dev/null || echo 0
}

count_app_windows_total() {
    local app_id="$1"
    "$AEROSPACE" list-windows --monitor all --app-bundle-id "$app_id" --count 2>/dev/null || echo 0
}

find_first_workspace_with_capacity() {
    local max="$1"
    shift
    local workspaces=("$@")

    local ws
    for ws in "${workspaces[@]}"; do
        local count
        count="$(count_windows_in_ws "$ws")"
        if [[ "$count" -lt "$max" ]]; then
            echo "$ws"
            return 0
        fi
    done

    return 1
}

evict_non_ghostty_from_workspace_5() {
    "$AEROSPACE" list-windows --workspace "$GHOSTTY_OVERFLOW_WS" --format '%{window-id}%{tab}%{app-bundle-id}' 2>/dev/null |
        awk -F'\t' -v ghost="$GHOSTTY_ID" '$2 != ghost { print $1 }' |
        while IFS= read -r other_id; do
            [[ -n "$other_id" ]] || continue
            dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${NON_GHOSTTY_OVERFLOW_WORKSPACES[@]}")" || dest="$NON_GHOSTTY_OVERFLOW_WS"
            "$AEROSPACE" move-node-to-workspace --window-id "$other_id" "$dest" 2>/dev/null || true
        done
}

place_ghostty_window() {
    local window_id="$1"

    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    local target
    if [[ "$ghostty_total" -le "$MAX_PER_WS" ]]; then
        target="$GHOSTTY_PRIMARY_WS"
    else
        local in_primary
        in_primary="$(count_app_windows_in_ws "$GHOSTTY_PRIMARY_WS" "$GHOSTTY_ID")"
        if [[ "$in_primary" -lt "$MAX_PER_WS" ]]; then
            target="$GHOSTTY_PRIMARY_WS"
        else
            target="$GHOSTTY_OVERFLOW_WS"
        fi
    fi

    if [[ "$target" == "$GHOSTTY_OVERFLOW_WS" ]]; then
        evict_non_ghostty_from_workspace_5
    fi

    "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$target" 2>/dev/null || true
}

enforce_workspace_window_cap_for_new_window() {
    local window_id="$1"

    local info
    info="$(get_window_info "$window_id")"
    [[ -n "$info" ]] || return 0

    local app_id workspace
    app_id="$(awk -F'\t' '{ print $2 }' <<<"$info")"
    workspace="$(awk -F'\t' '{ print $3 }' <<<"$info")"

    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
        place_ghostty_window "$window_id"
        return 0
    fi

    if [[ "$ghostty_total" -gt "$MAX_PER_WS" ]] && [[ "$workspace" == "$GHOSTTY_OVERFLOW_WS" ]]; then
        "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$NON_GHOSTTY_OVERFLOW_WS" 2>/dev/null || true
        workspace="$NON_GHOSTTY_OVERFLOW_WS"
    fi

    local count
    count="$(count_windows_in_ws "$workspace")"
    if [[ "$count" -le "$MAX_PER_WS" ]]; then
        return 0
    fi

    local candidates=("${OVERFLOW_WORKSPACES[@]}")
    if [[ "$ghostty_total" -gt "$MAX_PER_WS" ]]; then
        candidates=("${NON_GHOSTTY_OVERFLOW_WORKSPACES[@]}")
    fi

    local dest
    dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${candidates[@]}")" || return 0

    "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$dest" 2>/dev/null || true
}

rebalance_ghostty_workspaces() {
    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    if [[ "$ghostty_total" -le "$MAX_PER_WS" ]]; then
        "$AEROSPACE" list-windows --monitor all --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}%{tab}%{workspace}' 2>/dev/null |
            awk -F'\t' -v ws="$GHOSTTY_PRIMARY_WS" '$2 != ws { print $1 }' |
            while IFS= read -r wid; do
                [[ -n "$wid" ]] || continue
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$GHOSTTY_PRIMARY_WS" 2>/dev/null || true
            done
        return 0
    fi

    evict_non_ghostty_from_workspace_5
}

case "$mode" in
    sweep)
        rebalance_ghostty_workspaces
        trigger_sketchybar_workspace_update
        exit 0
        ;;
    on-window-detected)
        window_id="${AEROSPACE_WINDOW_ID:-}"
        [[ -n "$window_id" ]] || exit 0
        sleep 0.25
        enforce_workspace_window_cap_for_new_window "$window_id"
        trigger_sketchybar_workspace_update
        exit 0
        ;;
    *)
        echo "Usage: $(basename "$0") {on-window-detected|sweep}" >&2
        exit 2
        ;;
esac
