#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
SCRIPT_WIFI="$RELPATH/plugins/wifi/script.sh"
SCRIPT_CLICK_WIFI="$RELPATH/plugins/wifi/click.sh"

wifi=(
    script="$SCRIPT_WIFI"
    click_script="$SCRIPT_CLICK_WIFI"
    label="Searching..."
    icon=􀙥
    icon.color=$SUBTLE
    icon.padding_right=0
    label.max_chars=10
    label.font="$FONT:Semibold:10.0"
    padding_left=0
    padding_right=5
)

sketchybar --add item wifi right \
    --set wifi "${wifi[@]}" \
    --subscribe wifi wifi_change mouse.entered mouse.exited
