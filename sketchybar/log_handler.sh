#!/usr/bin/env bash

# Simplified log handler for sketchybar
# Based on Kcraft059/sketchybar-config

: "${LOG_LEVEL:="none"}"

if [[ $LOG_LEVEL != "none" ]]; then
    __getKeywordLevel() {
        case "$1" in
        "none") echo 0 ;;
        "info") echo 1 ;;
        "debug") echo 2 ;;
        "vomit") echo 3 ;;
        *) echo 0; return 1 ;;
        esac
    }

    LOG_LEVEL_INDEX=$(__getKeywordLevel "$LOG_LEVEL")

    sendErr() {
        [ -z "$2" ] && return 1
        if [ "$LOG_LEVEL_INDEX" -ge "$(__getKeywordLevel "$2")" ]; then
            >&2 echo "[$(date '+%H:%M:%S')] [Error] $1"
        fi
    }

    sendWarn() {
        [ -z "$2" ] && return 1
        if [ "$LOG_LEVEL_INDEX" -ge "$(__getKeywordLevel "$2")" ]; then
            >&1 echo "[$(date '+%H:%M:%S')] [Warn] $1"
        fi
    }

    sendLog() {
        [ -z "$2" ] && return 1
        if [ "$LOG_LEVEL_INDEX" -ge "$(__getKeywordLevel "$2")" ]; then
            >&1 echo "[$(date '+%H:%M:%S')] [Info] $1"
        fi
    }
else
    sendErr() { :; }
    sendWarn() { :; }
    sendLog() { :; }
fi
