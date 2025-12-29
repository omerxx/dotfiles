#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

update() {
    delay=$((59 - $(date '+%-S')))
    sleep $delay

    while [[ $(date '+%S') != "00" ]]; do
        sleep 0.1
    done

    sketchybar --set $NAME icon="$(date '+%a %d. %b')" label="$(date '+%H:%M')"
}

update
