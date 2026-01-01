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

if [[ "${BUTTON:-}" == "right" ]]; then
  osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  if not (exists process "CodexBar") then return

  tell process "CodexBar"
    if (count of menu bars) < 2 then return

    click menu bar item 1 of menu bar 2
    delay 0.1

    if exists menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2
      return
    end if

    if exists menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
    end if
  end tell
end tell
APPLESCRIPT
  exit 0
fi

osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  if not (exists process "CodexBar") then return

  tell process "CodexBar"
    if (count of menu bars) < 2 then return
    click menu bar item 1 of menu bar 2
  end tell
end tell
APPLESCRIPT

exit 0
