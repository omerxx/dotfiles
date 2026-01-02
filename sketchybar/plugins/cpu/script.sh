#!/bin/sh

CPU=$(top -l 1 | awk '/^CPU usage:/ {print $3}' | tr -d '%' | cut -d "." -f1)
sketchybar --set "$NAME" label="${CPU}%"
