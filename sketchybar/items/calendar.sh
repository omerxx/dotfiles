#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
SCRIPT_CALENDAR="$RELPATH/plugins/calendar/script.sh"

calendar=(
    icon="$(date '+%a %d. %b')"
    label="$(date '+%H:%M:%S')"
    icon.font="$FONT:Black:12.0"
    icon.padding_right=0
    label.width=54
    label.align=center
    label.padding_right=0
    update_freq=1
    script="$SCRIPT_CALENDAR"
    click_script="open -a Itsycal"
)

sketchybar --add item calendar right \
    --set calendar "${calendar[@]}"
