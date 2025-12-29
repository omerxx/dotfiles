#!/usr/bin/env bash

RELPATH="$HOME/.config/sketchybar/plugins/calendar"
BINARY="$RELPATH/calendar_events"

if [ ! -x "$BINARY" ]; then
    sketchybar --set $NAME label="No events" drawing=off
    exit 0
fi

EVENT=$("$BINARY" 1 2>/dev/null | head -1)

if [ -z "$EVENT" ]; then
    sketchybar --set $NAME label="No events" drawing=off
else
    sketchybar --set $NAME label="$EVENT" drawing=on
fi
