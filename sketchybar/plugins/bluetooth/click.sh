#!/usr/bin/env bash

BLUEUTIL="/opt/homebrew/bin/blueutil"

if [ ! -x "$BLUEUTIL" ]; then
    open "x-apple.systempreferences:com.apple.BluetoothSettings"
    exit 0
fi

POWER=$("$BLUEUTIL" --power 2>/dev/null)

if [ "$POWER" = "1" ]; then
    "$BLUEUTIL" --power 0
else
    "$BLUEUTIL" --power 1
fi

sleep 0.5
~/.config/sketchybar/plugins/bluetooth/script.sh
