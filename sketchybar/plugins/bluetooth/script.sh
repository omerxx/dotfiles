#!/usr/bin/env bash

BLUEUTIL="/opt/homebrew/bin/blueutil"

if [ ! -x "$BLUEUTIL" ]; then
    sketchybar --set $NAME icon=􀪷 label="N/A"
    exit 0
fi

POWER=$("$BLUEUTIL" --power 2>/dev/null)
CONNECTED=$("$BLUEUTIL" --connected 2>/dev/null | wc -l | tr -d ' ')

if [ "$POWER" = "1" ]; then
    if [ "$CONNECTED" -gt 0 ]; then
        sketchybar --set $NAME icon=􀲏 label="$CONNECTED"
    else
        sketchybar --set $NAME icon=􀪷 label=""
    fi
else
    sketchybar --set $NAME icon=􀲎 label="Off"
fi
