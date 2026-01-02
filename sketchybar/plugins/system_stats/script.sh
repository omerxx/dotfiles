#!/usr/bin/env bash

percent_or_empty() {
  local raw="${1:-}"
  awk -v v="$raw" 'BEGIN {
    gsub(/[^0-9.]/, "", v)
    if (v == "") exit 1
    if (v < 0) v = 0
    if (v > 100) v = 100
    printf "%.0f", v
  }'
}

CPU_PCT="$(percent_or_empty "${CPU_USAGE:-}" 2>/dev/null || true)"
RAM_PCT="$(percent_or_empty "${RAM_USAGE:-}" 2>/dev/null || true)"

if [[ -n "$CPU_PCT" ]]; then
  CPU_POINT="$(awk -v v="$CPU_PCT" 'BEGIN { printf "%.4f", v/100 }')"
  sketchybar --set cpu label="${CPU_PCT}%"
  sketchybar --push cpu_graph "$CPU_POINT"
else
  sketchybar --set cpu label="--"
fi

if [[ -n "$RAM_PCT" ]]; then
  sketchybar --set ram label="${RAM_PCT}%"
  sketchybar --set ram_graph slider.percentage="$RAM_PCT"
else
  sketchybar --set ram label="--"
  sketchybar --set ram_graph slider.percentage=0
fi
