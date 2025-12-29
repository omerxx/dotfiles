#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

WORKSPACE_ID=${1:-${NAME#space.}}

RELPATH="$HOME/.config/sketchybar"
source "$RELPATH/colors.sh"

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
    SELECTED="true"
else
    SELECTED="false"
fi

update() {
    if [ "$SELECTED" = "true" ]; then
        sketchybar --animate tanh 20 --set $NAME \
            icon.highlight=true \
            icon.color=0xff1e1e2e \
            background.color=0xffcba6f7 \
            background.drawing=on
    else
        sketchybar --animate tanh 20 --set $NAME \
            icon.highlight=false \
            icon.color=0xff6c7086 \
            background.color=0xff313244
    fi
}

mouse_clicked() {
    if [ "$BUTTON" = "right" ]; then
        echo "Right click on aerospace workspace not supported"
    else
        aerospace workspace "$WORKSPACE_ID" 2>/dev/null
    fi
}

case "$SENDER" in
"mouse.clicked")
    mouse_clicked
    ;;
"mouse.entered")
    ;;
*)
    "$RELPATH/plugins/spaces/aerospace/script-windows.sh" "$WORKSPACE_ID"
    update
    ;;
esac
