#!/bin/sh

RAM=$(vm_stat | awk '
  /Pages free:/        { free=$3 }
  /Pages active:/      { active=$3 }
  /Pages inactive:/    { inactive=$3 }
  /Pages speculative:/ { speculative=$3 }
  END {
    gsub(/\./, "", free)
    gsub(/\./, "", active)
    gsub(/\./, "", inactive)
    gsub(/\./, "", speculative)
    total = free + active + inactive + speculative
    used = active + inactive
    if (total > 0) print int(100 * used / total)
    else print 0
  }
')
sketchybar --set "$NAME" label="${RAM}%"
