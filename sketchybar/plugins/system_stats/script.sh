#!/usr/bin/env bash

clamp_percent() {
  local raw="${1:-}"
  awk -v v="$raw" 'BEGIN {
    gsub(/[^0-9.]/, "", v)
    if (v == "") v = 0
    if (v < 0) v = 0
    if (v > 100) v = 100
    printf "%.0f", v
  }'
}

CPU_PCT="$(clamp_percent "${CPU_USAGE:-}")"
RAM_PCT="$(clamp_percent "${RAM_USAGE:-}")"

CPU_POINT="$(awk -v v="$CPU_PCT" 'BEGIN { printf "%.4f", v/100 }')"
RAM_POINT="$(awk -v v="$RAM_PCT" 'BEGIN { printf "%.4f", v/100 }')"

sketchybar --set cpu label="${CPU_PCT}%"
sketchybar --set ram label="${RAM_PCT}%"
sketchybar --push cpu_graph "$CPU_POINT"
sketchybar --push ram_graph "$RAM_POINT"
