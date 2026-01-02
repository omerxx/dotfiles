#!/bin/sh

CPU=$(top -l 1 -n 0 | awk '/^CPU usage:/ {
  gsub(/%/, "")
  user = $3
  sys = $5
  printf "%.0f", user + sys
}')

sketchybar --set "$NAME" label="${CPU}%"
