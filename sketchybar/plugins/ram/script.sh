#!/bin/sh

RAM=$(vm_stat | awk '
  BEGIN { pagesize = 16384 }
  /Pages active:/              { active = $3 }
  /Pages wired down:/          { wired = $4 }
  /Pages occupied by compressor:/ { compressed = $5 }
  END {
    gsub(/\./, "", active)
    gsub(/\./, "", wired)
    gsub(/\./, "", compressed)
    total_bytes = 17179869184
    used_bytes = (active + wired + compressed) * pagesize
    printf "%.0f", (used_bytes / total_bytes) * 100
  }
')

sketchybar --set "$NAME" label="${RAM}%"
