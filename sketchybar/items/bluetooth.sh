#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
SCRIPT_CLICK_BLUETOOTH="$RELPATH/plugins/bluetooth/click.sh"

bluetooth=(
    drawing=on
    padding_left=0
    padding_right=5
    alias.color=$GLOW
    label.drawing=off
    icon.drawing=off
    click_script="$SCRIPT_CLICK_BLUETOOTH"
)

sketchybar --add alias "Control Center,Bluetooth" right \
    --set "Control Center,Bluetooth" "${bluetooth[@]}"
