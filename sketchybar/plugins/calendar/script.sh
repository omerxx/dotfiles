#!/usr/bin/env bash

RELPATH="$HOME/.config/sketchybar/plugins/calendar"

update() {
    sketchybar --set $NAME icon="$(date '+%a %d %b')" label="$(date '+%H:%M')"
}

update
