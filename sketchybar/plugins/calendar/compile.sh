#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
swiftc "$SCRIPT_DIR/CalendarEvents.swift" -o "$SCRIPT_DIR/calendar_events"
chmod +x "$SCRIPT_DIR/calendar_events"
echo "Compiled calendar_events binary"
