#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
source "$RELPATH/colors.sh"

ICON_HOTSPOT=􀉤
ICON_WIFI=􀙇
ICON_WIFI_ERROR=􀙥
ICON_WIFI_OFF=􀙈

getname() {
    WIFI_PORT=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
    WIFI="$(ipconfig getsummary $WIFI_PORT | awk -F': ' '/ SSID : / {print $2}')"
    HOTSPOT=$(ipconfig getsummary $WIFI_PORT | grep sname | awk '{print $3}')
    IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
    PUBLIC_IP=$(curl -m 2 https://ipinfo.io 2>/dev/null 1>&2; echo $?)

    if [[ $HOTSPOT != "" ]]; then
        ICON=$ICON_HOTSPOT
        ICON_COLOR=$GLOW
        LABEL=$HOTSPOT
    elif [[ $WIFI != "" ]]; then
        ICON=$ICON_WIFI
        ICON_COLOR=$SELECT
        LABEL="$WIFI"
    elif [[ $IP_ADDRESS != "" ]]; then
        ICON=$ICON_WIFI
        ICON_COLOR=$WARN
        LABEL="on"
    else
        ICON=$ICON_WIFI_OFF
        ICON_COLOR=$CRITICAL
        LABEL="off"
    fi

    if [[ $PUBLIC_IP != "0" && $LABEL != "off" ]]; then
        ICON=$ICON_WIFI_ERROR
        ICON_COLOR=$SUBTLE
        LABEL="$WIFI (no internet)"
    fi

    wifi=(
        icon=$ICON
        label="$LABEL"
        icon.color=$ICON_COLOR
    )

    if [[ $WIFI == "<redacted>" ]]; then
        wifi+=(label.drawing=off)
    else
        wifi+=(label.drawing=on)
    fi

    sketchybar --set $NAME "${wifi[@]}"
}

setscroll() {
    STATE="$(sketchybar --query $NAME | sed 's/\\n//g; s/\\\$//g; s/\\ //g' | jq -r '.geometry.scroll_texts')"

    case "$1" in
    "on") target="off" ;;
    "off") target="on" ;;
    esac

    if [[ "$STATE" == "$target" ]]; then
        sketchybar --set "$NAME" scroll_texts=$1
    fi
}

case "$SENDER" in
"mouse.entered") setscroll on ;;
"mouse.exited") setscroll off ;;
*) getname ;;
esac
