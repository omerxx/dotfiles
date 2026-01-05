#!/usr/bin/env bash
set -e

AEROSPACE=/opt/homebrew/bin/aerospace

PASSES="${PASSES:-25}"
SLEEP_SECONDS="${SLEEP_SECONDS:-0.5}"

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

apply_rules_once() {
    local had_changes=0

    shopt -s nocasematch

    while IFS=$'\t' read -r window_id app_bundle_id app_name workspace window_title; do
        [[ -n "$window_id" ]] || continue

        local target_workspace=""

        case "$app_bundle_id" in
            com.readdle.SparkDesktop-setapp | md.obsidian | com.google.Chrome | org.mozilla.firefox)
                target_workspace="2"
                ;;
            com.tinyspeck.slackmacgap | com.hnc.Discord | ru.keepcoder.Telegram)
                target_workspace="3"
                ;;
            com.microsoft.VSCode | com.exafunction.windsurf | dev.zed.Zed)
                target_workspace="4"
                ;;
            proseek.io.vn.Quotio)
                target_workspace="4"
                ;;
        esac

        if [[ -z "$target_workspace" ]]; then
            case "$app_name" in
                *arc*) target_workspace="2" ;;
                *linear*) target_workspace="4" ;;
                *cursor*) target_workspace="4" ;;
                *antigravity*) target_workspace="4" ;;
                *quotio*) target_workspace="4" ;;
            esac
        fi

        if [[ -n "$target_workspace" ]] && [[ "$workspace" != "$target_workspace" ]]; then
            "$AEROSPACE" move-node-to-workspace --window-id "$window_id" "$target_workspace" >/dev/null 2>&1 || true
            had_changes=1
        fi

        case "$app_bundle_id" in
            com.apple.finder | com.apple.FaceTime | com.apple.mail | com.apple.QuickTimePlayerX | com.apple.SecurityAgent | \
                com.apple.coreservices.uiagent | com.apple.IOUIAgent | com.apple.NetAuthAgent | com.apple.authorizationhost | \
                com.apple.systempreferences)
                "$AEROSPACE" layout --window-id "$window_id" floating >/dev/null 2>&1 || true
                ;;
        esac

        case "$window_title" in
            *password* | *authenticate* | *authorization* | *settings* | *preferences*)
                "$AEROSPACE" layout --window-id "$window_id" floating >/dev/null 2>&1 || true
                ;;
        esac
    done < <(
        "$AEROSPACE" list-windows --monitor all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null || true
    )

    shopt -u nocasematch

    return "$had_changes"
}

sleep 1

for _ in $(seq 1 "$PASSES"); do
    if apply_rules_once; then
        sleep "$SLEEP_SECONDS"
    else
        trigger_sketchybar_workspace_update
        sleep "$SLEEP_SECONDS"
    fi
done

trigger_sketchybar_workspace_update
