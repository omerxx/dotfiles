#!/usr/bin/env bash

# Separator helper for sketchybar
# Based on Kcraft059/sketchybar-config

add_separator() {
    local id=${1:-0}
    local position=${2:-right}
    local icon=${3:-"|"}
    
    separator=(
        icon="$icon"
        icon.color=$SUBTLE
        icon.font="$FONT:Bold:16.0"
        icon.y_offset=2
        label.drawing=off
        icon.padding_left=0
        icon.padding_right=0
    )

    sketchybar --add item separator.$id $position \
        --set separator.$id "${separator[@]}"

    sendLog "Added separator with icon \"$icon\", id $id at $position" "debug"
}
