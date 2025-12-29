#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
source "$RELPATH/plugins/icon_map.sh"

update_workspace_windows() {
    local workspace_id=$1

    apps=$(aerospace list-windows --workspace "$workspace_id" --format '%{app-name}' 2>/dev/null)
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

    icon_strip=" "
    if [ "${apps}" != "" ]; then
        while read -r app; do
            __icon_map "$app"
            icon_strip+=" $icon_result"
        done <<<"${apps}"
        sketchybar --set space.$workspace_id label="$icon_strip" label.drawing=on label.width=dynamic drawing=on

        if [ "$FOCUSED_WORKSPACE" = "$workspace_id" ]; then
            sketchybar --set space.$workspace_id background.drawing=on background.color=0xffcba6f7
        else
            sketchybar --set space.$workspace_id background.drawing=on background.color=0xff313244
        fi
    else
        if [ "$FOCUSED_WORKSPACE" = "$workspace_id" ]; then
            sketchybar --set space.$workspace_id label.drawing=off label.width=0 background.drawing=on background.color=0xffcba6f7 drawing=on
        else
            sketchybar --set space.$workspace_id label.drawing=off label.width=0 background.drawing=off drawing=off
        fi
    fi
}

update_workspace_windows "$1"
