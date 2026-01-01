#!/usr/bin/env bash
set -e

RELPATH="$HOME/.config/sketchybar"

open -g -b com.steipete.codexbar >/dev/null 2>&1 || open -ga "CodexBar" >/dev/null 2>&1 || true

for _ in {1..20}; do
  if pgrep -x "CodexBar" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  if not (exists application process "CodexBar") then return

  tell application process "CodexBar"
    if (count of menu bars) is 0 then return

    tell menu bar 1
      if (count of menu bar items) is 0 then return

      click menu bar item 1
    end tell
  end tell
end tell
APPLESCRIPT

exit 0
