# sketchybar/

## Purpose
SketchyBar status bar config, plugin scripts, and helper binary source.

## Contents
- `sketchybarrc` — Main SketchyBar config.
- `colors.sh`, `icons.sh` — Shared constants.
- `items/` — Per-item setup scripts (spaces, calendar, cpu, etc.).
- `plugins/` — Event/plugin scripts.
- `helper/` — C helper source and makefile.

## Current Stow target result
- `~/.config/sketchybarrc`
- `~/.config/colors.sh`, `~/.config/icons.sh`
- `~/.config/items/...`, `~/.config/plugins/...`, `~/.config/helper/...`

## Usage status
- Potentially mis-targeted; typical layout is under `~/.config/sketchybar/`.
