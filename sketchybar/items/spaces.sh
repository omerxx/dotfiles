#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config (aerospace support)

RELPATH="$HOME/.config/sketchybar"
SCRIPT_SPACES="$RELPATH/plugins/spaces/aerospace/script-space.sh"

dummy_space=(
    icon.padding_left=6
    icon.padding_right=7
    icon.color=$NOTICE
    padding_left=3
    padding_right=3
    background.color=$HIGH_MED
    background.height=$((BAR_HEIGHT - 12))
    background.corner_radius=$((ZONE_CORNER_RADIUS - 2))
    background.drawing=off
    icon.highlight_color=$CRITICAL
    label.padding_right=20
    label.font="sketchybar-app-font:Regular:16.0"
    label.background.height=$((BAR_HEIGHT - 12))
    label.background.drawing=off
    label.background.color=$HIGH_HIGH
    label.background.corner_radius=$((ZONE_CORNER_RADIUS - 2))
    label.y_offset=-1
    label.drawing=on
    label.width=0
)

separator=(
    icon=
    label.drawing=off
    icon.font="$FONT:Semibold:14.0"
    associated_display=active
    icon.color=$SUBTLE
)

sketchybar --add event aerospace_workspace_change

SPACES=($(aerospace list-workspaces --all 2>/dev/null))

for sid in "${SPACES[@]}"; do
    space=("${dummy_space[@]}")
    space+=(
        icon="$sid"
        script="$SCRIPT_SPACES $sid"
        drawing=on
    )

    sketchybar --add item space.$sid left \
        --set space.$sid "${space[@]}" \
        --subscribe space.$sid aerospace_workspace_change mouse.clicked mouse.entered
done

sketchybar --add item separator left \
    --set separator "${separator[@]}"

sketchybar --add bracket spaces '/space\..*/' \
    --set spaces "${zones[@]}"
