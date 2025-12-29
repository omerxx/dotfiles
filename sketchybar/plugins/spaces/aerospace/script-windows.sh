#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
source "$RELPATH/plugins/icon_map.sh"

update_workspace_windows() {
    local workspace_id=$1

    apps=$(aerospace list-windows --workspace "$workspace_id" --format '%{app-name}' 2>/dev/null | sort -u)

    icon_strip=" "
    if [ "${apps}" != "" ]; then
        while read -r app; do
            __icon_map "$app"
            icon_strip+=" $icon_result"
        done <<<"${apps}"
        sketchybar --set space.$workspace_id label="$icon_strip" label.drawing=on

        FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

        if ! [ "$FOCUSED_WORKSPACE" = "$workspace_id" ]; then
            sketchybar --set space.$workspace_id background.drawing=on
        else
            sketchybar --set space.$workspace_id background.drawing=off
        fi
    else
        icon_strip=" -"
        sketchybar --set space.$workspace_id label.drawing=off background.drawing=off
    fi
}

update_workspace_windows "$1"
