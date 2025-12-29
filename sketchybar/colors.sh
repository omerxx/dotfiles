#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config (Rosé Pine Moon)

BAR_TRANSPARENCY=true
if [[ $BAR_TRANSPARENCY == true ]]; then
    TFrate=160
else
    TFrate=255
fi

TFp=$(printf '%02X' $TFrate)
[ $((TFrate + 20)) -lt 255 ] && TFrate=$((TFrate + 20))
TFs=$(printf '%02X' $TFrate)

export BASE=0x${TFp}232136
export SURFACE=0x${TFp}2a273f
export OVERLAY=0x${TFp}393552
export MUTED=0x${TFp}6e6a86
export HIGH_LOW=0x${TFs}2a283e
export HIGH_MED=0x${TFs}44415a
export HIGH_HIGH=0x${TFs}56526e
export SUBTLE=0xff908caa
export TEXT=0xffe0def4
export CRITICAL=0xffeb6f92
export NOTICE=0xfff6c177
export WARN=0xffea9a97
export SELECT=0xff3e8fb0
export GLOW=0xff9ccfd8
export ACTIVE=0xffc4a7e7

export BLACK=0xff181926
export WHITE=0xffe0def4
export TRANSPARENT=0x00000000

OS_VERSION="$(sw_vers -productVersion)"
if [ "$(echo "$OS_VERSION" | awk -F. '{print $1}')" -gt 15 ]; then
    export BAR_COLOR=0x${TFp}232137
    export BORDER_COLOR=0x60808080
else
    export BAR_COLOR=0x${TFp}414354
    export BORDER_COLOR=0x${TFp}4D525B
fi

export ICON_COLOR=$TEXT
export LABEL_COLOR=$TEXT
export POPUP_BACKGROUND_COLOR=0x${TFp}393552
export POPUP_BORDER_COLOR=$HIGH_MED
export SHADOW_COLOR=$TEXT
