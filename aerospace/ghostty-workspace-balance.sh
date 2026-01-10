#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace

MAX_PER_WS=3

GHOSTTY_ID='com.mitchellh.ghostty'
GHOSTTY_PRIMARY_WS='1'
GHOSTTY_OVERFLOW_WS='5'
NON_GHOSTTY_OVERFLOW_WS='6'
QUOTIO_ID='proseek.io.vn.Quotio'
QUOTIO_WORKSPACE='4'
LOCAL_AUTH_UIAGENT_ID='com.apple.LocalAuthentication.UIAgent'
ONEPASSWORD_ID='com.1password.1password'

# Apps that should be floating - skip workspace cap enforcement for these
# Must match the floating rules in aerospace.toml
FLOATING_APP_PATTERNS=(
    'com.apple.finder'
    'com.apple.FaceTime'
    'com.apple.mail'
    'com.apple.QuickTimePlayerX'
    'com.apple.SecurityAgent'
    'com.apple.authorizationhost'
    'com.apple.coreservices.uiagent'
    'com.apple.IOUIAgent'
    'com.apple.LocalAuthentication.UIAgent'
    'com.apple.NetAuthAgent'
    'com.apple.systempreferences'
)

OVERFLOW_WORKSPACES_WITH_WS5=(5 6 7 8 9)
OVERFLOW_WORKSPACES_WITHOUT_WS5=(6 7 8 9)
NON_GHOSTTY_OVERFLOW_WORKSPACES=(6 7 8 9)

mode="${1:-on-window-detected}"
WATCH_INTERVAL_SECONDS="${WATCH_INTERVAL_SECONDS:-0.35}"

trigger_sketchybar_workspace_update() {
    local sketchybar_bin="/opt/homebrew/bin/sketchybar"
    if [[ -x "$sketchybar_bin" ]]; then
        "$sketchybar_bin" --trigger aerospace_workspace_change >/dev/null 2>&1 || true
        return 0
    fi

    if command -v sketchybar >/dev/null 2>&1; then
        sketchybar --trigger aerospace_workspace_change >/dev/null 2>&1 || true
    fi
}

is_floating_app() {
    local app_id="$1"
    local pattern
    for pattern in "${FLOATING_APP_PATTERNS[@]}"; do
        if [[ "$app_id" == "$pattern" ]]; then
            return 0
        fi
    done
    return 1
}

get_window_info() {
    local window_id="$1"
    "$AEROSPACE" list-windows --monitor all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null |
        awk -F'\t' -v id="$window_id" '$1 == id { print $0; exit }'
}

is_onepassword_access_request_window() {
    local app_id="$1"
    local window_title="$2"

    if [[ "$app_id" != "$ONEPASSWORD_ID" ]]; then
        return 1
    fi

    [[ "$window_title" =~ [1-9]Password[[:space:]]+[Aa]ccess[[:space:]]+[Rr]equested ]] || return 1
    return 0
}

count_windows_in_ws() {
    local ws="$1"
    "$AEROSPACE" list-windows --workspace "$ws" --count 2>/dev/null || echo 0
}

count_capped_windows_in_ws() {
    local ws="$1"
    local count=0
    local app_id window_title

    while IFS=$'\t' read -r app_id window_title; do
        [[ -n "$app_id" ]] || continue
        if is_onepassword_access_request_window "$app_id" "$window_title"; then
            continue
        fi
        if ! is_floating_app "$app_id"; then
            count=$((count + 1))
        fi
    done < <("$AEROSPACE" list-windows --workspace "$ws" --format '%{app-bundle-id}%{tab}%{window-title}' 2>/dev/null || true)

    echo "$count"
}

is_transient_window() {
    local app_id="$1"
    local window_title="$2"

    if [[ "$app_id" == "$LOCAL_AUTH_UIAGENT_ID" ]]; then
        return 0
    fi

    if is_onepassword_access_request_window "$app_id" "$window_title"; then
        return 0
    fi

    return 1
}

workspace_for_pinned_app() {
    local app_id="$1"
    local app_name="${2:-}"

    case "$app_id" in
        # Workspace 2: Chrome, Obsidian, Spark
        com.google.Chrome | com.google.Chrome.beta | com.google.Chrome.canary | md.obsidian | com.readdle.SparkDesktop-setapp | com.readdle.SparkDesktop)
            echo "2"
            return 0
            ;;
        # Workspace 3: Discord, Slack, Telegram
        com.tinyspeck.slackmacgap | com.hnc.Discord | com.discord.Discord | ru.keepcoder.Telegram | org.telegram.desktop)
            echo "3"
            return 0
            ;;
        # Workspace 4: Cursor, Windsurf, Quotio
        com.exafunction.windsurf | "$QUOTIO_ID")
            echo "4"
            return 0
            ;;
    esac

    local name_lc=""
    name_lc="$(printf '%s' "$app_name" | tr '[:upper:]' '[:lower:]')"
    case "$name_lc" in
        *chrome* | *obsidian* | *spark*)
            echo "2"
            return 0
            ;;
        *slack* | *discord* | *telegram*)
            echo "3"
            return 0
            ;;
        *cursor* | *windsurf* | *quotio*)
            echo "4"
            return 0
            ;;
    esac

    return 1
}

enforce_pinned_app_workspaces() {
    "$AEROSPACE" list-windows --monitor all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null |
        while IFS=$'\t' read -r wid app_id app_name ws window_title; do
            [[ -n "$wid" ]] || continue

            if is_transient_window "$app_id" "$window_title"; then
                continue
            fi

            if is_floating_app "$app_id"; then
                continue
            fi

            local target=""
            target="$(workspace_for_pinned_app "$app_id" "$app_name" 2>/dev/null || true)"
            [[ -n "$target" ]] || continue

            if [[ "$ws" != "$target" ]]; then
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$target" 2>/dev/null || true
            fi
        done
}

evict_non_ghostty_from_workspace_1() {
    "$AEROSPACE" list-windows --workspace "$GHOSTTY_PRIMARY_WS" --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
        while IFS=$'\t' read -r wid app_id app_name window_title; do
            [[ -n "$wid" ]] || continue

            if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
                continue
            fi

            if is_transient_window "$app_id" "$window_title"; then
                continue
            fi

            if is_floating_app "$app_id"; then
                continue
            fi

            local dest=""
            dest="$(workspace_for_pinned_app "$app_id" "$app_name" 2>/dev/null || true)"
            if [[ -z "$dest" ]]; then
                dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" 2 3 4 2>/dev/null || true)"
                [[ -n "$dest" ]] || dest="$NON_GHOSTTY_OVERFLOW_WS"
            fi

            if [[ "$dest" != "$GHOSTTY_PRIMARY_WS" ]]; then
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$dest" 2>/dev/null || true
            fi
        done
}

count_nontransient_windows_in_ws() {
    local ws="$1"
    local count=0
    local app_id window_title

    while IFS=$'\t' read -r app_id window_title; do
        [[ -n "$app_id" ]] || continue
        if is_transient_window "$app_id" "$window_title"; then
            continue
        fi
        count=$((count + 1))
    done < <("$AEROSPACE" list-windows --workspace "$ws" --format '%{app-bundle-id}%{tab}%{window-title}' 2>/dev/null || true)

    echo "$count"
}

relocate_transient_windows_to_focused_workspace() {
    local focused_ws
    focused_ws="$("$AEROSPACE" list-workspaces --focused 2>/dev/null || true)"
    [[ -n "$focused_ws" ]] || return 0

    "$AEROSPACE" list-windows --monitor all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null |
        while IFS=$'\t' read -r wid app_id ws window_title; do
            [[ -n "$wid" ]] || continue
            if ! is_transient_window "$app_id" "$window_title"; then
                continue
            fi
            if [[ "$ws" == "$focused_ws" ]]; then
                continue
            fi
            "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$focused_ws" 2>/dev/null || true
        done
}

move_nontransient_windows_between_workspaces() {
    local src="$1"
    local dest="$2"

    "$AEROSPACE" list-windows --workspace "$src" --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
        while IFS=$'\t' read -r wid app_id app_name window_title; do
            [[ -n "$wid" ]] || continue
            if is_transient_window "$app_id" "$window_title"; then
                continue
            fi
            if workspace_for_pinned_app "$app_id" "$app_name" >/dev/null 2>&1; then
                continue
            fi
            "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$dest" 2>/dev/null || true
        done
}

compact_overflow_workspaces() {
    relocate_transient_windows_to_focused_workspace

    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    local targets=()
    if [[ "$ghostty_total" -gt "$MAX_PER_WS" ]]; then
        targets=("${NON_GHOSTTY_OVERFLOW_WORKSPACES[@]}")
    else
        targets=("${OVERFLOW_WORKSPACES_WITH_WS5[@]}")
    fi

    local occupied=()
    local ws
    for ws in "${targets[@]}"; do
        local count
        count="$(count_nontransient_windows_in_ws "$ws")"
        if [[ "$count" -gt 0 ]]; then
            occupied+=("$ws")
        fi
    done

    local i=0
    local src dest
    for src in "${occupied[@]}"; do
        dest="${targets[$i]:-}"
        [[ -n "$dest" ]] || break
        if [[ "$src" != "$dest" ]]; then
            move_nontransient_windows_between_workspaces "$src" "$dest"
        fi
        i=$((i + 1))
    done
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
        count="$(count_capped_windows_in_ws "$ws")"
        if [[ "$count" -lt "$max" ]]; then
            echo "$ws"
            return 0
        fi
    done

    return 1
}

evict_non_ghostty_from_workspace_5() {
    "$AEROSPACE" list-windows --workspace "$GHOSTTY_OVERFLOW_WS" --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
        while IFS=$'\t' read -r other_id app_id app_name window_title; do
            [[ -n "$other_id" ]] || continue
            if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
                continue
            fi
            if is_onepassword_access_request_window "$app_id" "$window_title"; then
                continue
            fi

            dest="$(workspace_for_pinned_app "$app_id" "$app_name" 2>/dev/null || true)"
            if [[ -z "$dest" ]]; then
                dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${NON_GHOSTTY_OVERFLOW_WORKSPACES[@]}")" || dest="$NON_GHOSTTY_OVERFLOW_WS"
            fi
            "$AEROSPACE" move-node-to-workspace --window-id "$other_id" "$dest" 2>/dev/null || true
        done
}

bounce_from_empty_overflow_workspace() {
    local focused_ws
    focused_ws="$("$AEROSPACE" list-workspaces --focused 2>/dev/null || true)"
    [[ -n "$focused_ws" ]] || return 0

    if [[ "$focused_ws" =~ ^[0-9]+$ ]] && [[ "$focused_ws" -ge 5 ]]; then
        local count
        count="$(count_windows_in_ws focused)"
        if [[ "$count" -eq 0 ]]; then
            "$AEROSPACE" workspace-back-and-forth 2>/dev/null || true
            return 0
        fi
    fi

    return 1
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

rebalance_workspace_window_caps() {
    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    local overflow_candidates
    if [[ "$ghostty_total" -gt "$MAX_PER_WS" ]]; then
        overflow_candidates=("${OVERFLOW_WORKSPACES_WITHOUT_WS5[@]}")
    else
        overflow_candidates=("${OVERFLOW_WORKSPACES_WITH_WS5[@]}")
    fi

    local ws
    for ws in 1 2 3 4 5 6 7 8 9; do
        local count
        count="$(count_capped_windows_in_ws "$ws")"
        if [[ "$count" -le "$MAX_PER_WS" ]]; then
            continue
        fi

        local extra
        extra=$((count - MAX_PER_WS))

        if [[ "$ws" == "$GHOSTTY_PRIMARY_WS" ]]; then
            "$AEROSPACE" list-windows --workspace "$ws" --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
                while IFS=$'\t' read -r wid app_id app_name window_title; do
                    [[ -n "$wid" ]] || continue
                    if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
                        continue
                    fi
                    if is_floating_app "$app_id"; then
                        continue
                    fi
                    if is_onepassword_access_request_window "$app_id" "$window_title"; then
                        continue
                    fi
                    if workspace_for_pinned_app "$app_id" "$app_name" >/dev/null 2>&1; then
                        continue
                    fi
                    echo "$wid"
                done |
                head -n "$extra" |
                while IFS= read -r wid; do
                    [[ -n "$wid" ]] || continue
                    dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${overflow_candidates[@]}")" || break
                    "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$dest" 2>/dev/null || true
                done
            continue
        fi

        "$AEROSPACE" list-windows --workspace "$ws" --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
            while IFS=$'\t' read -r wid app_id app_name window_title; do
                [[ -n "$wid" ]] || continue
                if is_floating_app "$app_id"; then
                    continue
                fi
                if is_onepassword_access_request_window "$app_id" "$window_title"; then
                    continue
                fi
                if workspace_for_pinned_app "$app_id" "$app_name" >/dev/null 2>&1; then
                    continue
                fi
                echo "$wid"
            done |
            awk -v max="$MAX_PER_WS" 'NR > max { print $1 }' |
            head -n "$extra" |
            while IFS= read -r wid; do
                [[ -n "$wid" ]] || continue
                dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${overflow_candidates[@]}")" || break
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$dest" 2>/dev/null || true
            done
    done
}

current_windows_signature() {
    "$AEROSPACE" list-windows --monitor all --format '%{workspace}%{tab}%{app-bundle-id}%{tab}%{window-id}' 2>/dev/null |
        LC_ALL=C sort ||
        true
}

watch_for_window_changes() {
    local lock_file="${TMPDIR:-/tmp}/aerospace-ghostty-workspace-balance.watch.pid"
    if [[ -f "$lock_file" ]]; then
        local existing_pid
        existing_pid="$(cat "$lock_file" 2>/dev/null || true)"
        if [[ "$existing_pid" =~ ^[0-9]+$ ]] && kill -0 "$existing_pid" 2>/dev/null; then
            local existing_cmd
            existing_cmd="$(ps -p "$existing_pid" -o command= 2>/dev/null || true)"
            if [[ "$existing_cmd" == *ghostty-workspace-balance.sh*watch* ]]; then
                exit 0
            fi
        fi
        rm -f "$lock_file" >/dev/null 2>&1 || true
    fi

    echo "$$" >"$lock_file"
    trap 'rm -f "$lock_file"' EXIT INT TERM

    local last_sig=""
    while true; do
        local sig
        sig="$(current_windows_signature)"

        if [[ "$sig" != "$last_sig" ]]; then
            last_sig="$sig"
            sleep 0.1
            enforce_pinned_app_workspaces
            rebalance_ghostty_workspaces
            evict_non_ghostty_from_workspace_1
            rebalance_workspace_window_caps
            compact_overflow_workspaces
            bounce_from_empty_overflow_workspace || true
            trigger_sketchybar_workspace_update
        else
            bounce_from_empty_overflow_workspace || true
        fi

        sleep "$WATCH_INTERVAL_SECONDS"
    done
}

enforce_workspace_window_cap_for_new_window() {
    local window_id="$1"

    local info
    info="$(get_window_info "$window_id")"
    [[ -n "$info" ]] || return 0

    local app_id app_name workspace window_title
    app_id="$(awk -F'\t' '{ print $2 }' <<<"$info")"
    app_name="$(awk -F'\t' '{ print $3 }' <<<"$info")"
    workspace="$(awk -F'\t' '{ print $4 }' <<<"$info")"
    window_title="$(awk -F'\t' '{ print $5 }' <<<"$info")"

    if [[ "$app_id" == "$LOCAL_AUTH_UIAGENT_ID" ]]; then
        local focused_ws
        focused_ws="$("$AEROSPACE" list-workspaces --focused 2>/dev/null || true)"

        if [[ -n "$focused_ws" ]] && [[ "$focused_ws" != "$workspace" ]]; then
            "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$focused_ws" 2>/dev/null || true
        fi

        return 0
    fi

    if is_onepassword_access_request_window "$app_id" "$window_title"; then
        local focused_ws
        focused_ws="$("$AEROSPACE" list-workspaces --focused 2>/dev/null || true)"

        if [[ -n "$focused_ws" ]] && [[ "$focused_ws" != "$workspace" ]]; then
            "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$focused_ws" 2>/dev/null || true
        fi

        return 0
    fi

    if is_floating_app "$app_id"; then
        return 0
    fi

    if [[ "$app_id" == "$GHOSTTY_ID" ]]; then
        place_ghostty_window "$window_id"
        return 0
    fi

    local pinned_target=""
    pinned_target="$(workspace_for_pinned_app "$app_id" "$app_name" 2>/dev/null || true)"
    if [[ -n "$pinned_target" ]]; then
        if [[ "$workspace" != "$pinned_target" ]]; then
            "$AEROSPACE" move-node-to-workspace --window-id "$window_id" "$pinned_target" 2>/dev/null || true
        fi
        return 0
    fi

    local ghostty_total
    ghostty_total="$(count_app_windows_total "$GHOSTTY_ID")"

    if [[ "$workspace" == "$GHOSTTY_OVERFLOW_WS" ]] && [[ "$ghostty_total" -gt "$MAX_PER_WS" ]]; then
        dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${NON_GHOSTTY_OVERFLOW_WORKSPACES[@]}")" || dest="$NON_GHOSTTY_OVERFLOW_WS"
        "$AEROSPACE" move-node-to-workspace --window-id "$window_id" --focus-follows-window "$dest" 2>/dev/null || true
        workspace="$dest"
    fi

    local count
    count="$(count_capped_windows_in_ws "$workspace")"
    if [[ "$count" -le "$MAX_PER_WS" ]]; then
        return 0
    fi

    local candidates=()
    if [[ "$ghostty_total" -gt "$MAX_PER_WS" ]]; then
        candidates=("${OVERFLOW_WORKSPACES_WITHOUT_WS5[@]}")
    else
        candidates=("${OVERFLOW_WORKSPACES_WITH_WS5[@]}")
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

    local in_primary
    in_primary="$(count_app_windows_in_ws "$GHOSTTY_PRIMARY_WS" "$GHOSTTY_ID")"
    if [[ "$in_primary" -lt "$MAX_PER_WS" ]]; then
        local needed
        needed=$((MAX_PER_WS - in_primary))

        "$AEROSPACE" list-windows --workspace "$GHOSTTY_OVERFLOW_WS" --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}' 2>/dev/null |
            awk -v n="$needed" 'NR <= n { print $1 }' |
            while IFS= read -r wid; do
                [[ -n "$wid" ]] || continue
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$GHOSTTY_PRIMARY_WS" 2>/dev/null || true
            done

        in_primary="$(count_app_windows_in_ws "$GHOSTTY_PRIMARY_WS" "$GHOSTTY_ID")"
        needed=$((MAX_PER_WS - in_primary))
        if [[ "$needed" -gt 0 ]]; then
            "$AEROSPACE" list-windows --monitor all --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}%{tab}%{workspace}' 2>/dev/null |
                awk -F'\t' -v primary="$GHOSTTY_PRIMARY_WS" -v overflow="$GHOSTTY_OVERFLOW_WS" '$2 != primary && $2 != overflow { print $1 }' |
                head -n "$needed" |
                while IFS= read -r wid; do
                    [[ -n "$wid" ]] || continue
                    "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$GHOSTTY_PRIMARY_WS" 2>/dev/null || true
                done
        fi
    fi

    in_primary="$(count_app_windows_in_ws "$GHOSTTY_PRIMARY_WS" "$GHOSTTY_ID")"
    if [[ "$in_primary" -gt "$MAX_PER_WS" ]]; then
        local extra
        extra=$((in_primary - MAX_PER_WS))

        "$AEROSPACE" list-windows --workspace "$GHOSTTY_PRIMARY_WS" --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}' 2>/dev/null |
            awk -v max="$MAX_PER_WS" 'NR > max { print $1 }' |
            head -n "$extra" |
            while IFS= read -r wid; do
                [[ -n "$wid" ]] || continue
                dest="$(find_first_workspace_with_capacity "$MAX_PER_WS" "${OVERFLOW_WORKSPACES_WITH_WS5[@]}")" || dest="$GHOSTTY_OVERFLOW_WS"
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$dest" 2>/dev/null || true
            done
    fi

    local in_overflow
    in_overflow="$(count_app_windows_in_ws "$GHOSTTY_OVERFLOW_WS" "$GHOSTTY_ID")"
    if [[ "$in_overflow" -lt "$MAX_PER_WS" ]]; then
        local needed
        needed=$((MAX_PER_WS - in_overflow))

        "$AEROSPACE" list-windows --monitor all --app-bundle-id "$GHOSTTY_ID" --format '%{window-id}%{tab}%{workspace}' 2>/dev/null |
            awk -F'\t' -v primary="$GHOSTTY_PRIMARY_WS" -v overflow="$GHOSTTY_OVERFLOW_WS" '$2 != primary && $2 != overflow { print $1 }' |
            head -n "$needed" |
            while IFS= read -r wid; do
                [[ -n "$wid" ]] || continue
                "$AEROSPACE" move-node-to-workspace --window-id "$wid" "$GHOSTTY_OVERFLOW_WS" 2>/dev/null || true
            done
    fi
}

case "$mode" in
    sweep)
        enforce_pinned_app_workspaces
        rebalance_ghostty_workspaces
        evict_non_ghostty_from_workspace_1
        rebalance_workspace_window_caps
        compact_overflow_workspaces
        trigger_sketchybar_workspace_update
        exit 0
        ;;
    watch)
        watch_for_window_changes
        exit 0
        ;;
    on-window-detected)
        window_id="${AEROSPACE_WINDOW_ID:-}"
        [[ -n "$window_id" ]] || exit 0
        sleep 0.25
        enforce_workspace_window_cap_for_new_window "$window_id"
        enforce_pinned_app_workspaces
        evict_non_ghostty_from_workspace_1
        rebalance_workspace_window_caps
        compact_overflow_workspaces
        trigger_sketchybar_workspace_update
        exit 0
        ;;
    *)
        echo "Usage: $(basename "$0") {on-window-detected|sweep}" >&2
        exit 2
        ;;
esac
