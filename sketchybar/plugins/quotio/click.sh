#!/usr/bin/env bash
set -e

if ! pgrep -x "Quotio" >/dev/null 2>&1; then
  open -g -a "Quotio" >/dev/null 2>&1 || true
  for _ in {1..20}; do
    pgrep -x "Quotio" >/dev/null 2>&1 && break
    sleep 0.1
  done
fi

# Right-click opens settings
if [[ "${BUTTON:-}" == "right" ]]; then
  osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  if not (exists process "Quotio") then return

  tell process "Quotio"
    if (count of menu bars) < 2 then return

    click menu bar item 1 of menu bar 2
    delay 0.1

    if exists menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2
      return
    end if

    if exists menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
      return
    end if

    if exists menu item "Preferences…" of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Preferences…" of menu 1 of menu bar item 1 of menu bar 2
      return
    end if

    if exists menu item "Preferences..." of menu 1 of menu bar item 1 of menu bar 2 then
      click menu item "Preferences..." of menu 1 of menu bar item 1 of menu bar 2
    end if
  end tell
end tell
APPLESCRIPT
  exit 0
fi

# Left-click opens the menu bar dropdown
osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  if not (exists process "Quotio") then return

  tell process "Quotio"
    if (count of menu bars) < 2 then return
    click menu bar item 1 of menu bar 2
  end tell
end tell
APPLESCRIPT

exit 0

