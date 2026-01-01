#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

RELPATH="$HOME/.config/sketchybar"
source "$RELPATH/plugins/icon_map.sh"

CACHE_ROOT="${HOME}/Library/Caches/sketchybar"
ICON_CACHE_DIR="${CACHE_ROOT}/app-icons"
WORKSPACE_ICON_DIR="${CACHE_ROOT}/workspace-icons"
APP_INDEX_FILE="${ICON_CACHE_DIR}/bundle-id-to-app-path.tsv"

ICON_SIZE=18
ICON_PADDING=2

build_app_index_if_needed() {
    if [ -s "$APP_INDEX_FILE" ]; then
        return 0
    fi

    mkdir -p "$ICON_CACHE_DIR"

    local tmp="${APP_INDEX_FILE}.tmp"
    : >"$tmp"

    local base
    for base in /Applications "$HOME/Applications" /System/Applications /System/Library/CoreServices; do
        [ -d "$base" ] || continue

        while IFS= read -r -d '' app_path; do
            local plist bundle_id
            plist="${app_path}/Contents/Info.plist"
            [ -f "$plist" ] || continue

            bundle_id=$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$plist" 2>/dev/null || true)
            [ -n "$bundle_id" ] || continue

            printf '%s\t%s\n' "$bundle_id" "$app_path" >>"$tmp"
        done < <(find "$base" -maxdepth 3 -type d -name "*.app" -prune -print0 2>/dev/null)
    done

    mv "$tmp" "$APP_INDEX_FILE"
}

app_path_for_bundle_id() {
    local bundle_id=$1
    build_app_index_if_needed

    local app_path
    app_path=$(
        awk -F '\t' -v id="$bundle_id" '$1 == id { path = $2 } END { if (path) print path }' "$APP_INDEX_FILE" 2>/dev/null
    )
    if [ -n "${app_path:-}" ] && [ -d "$app_path" ]; then
        echo "$app_path"
        return 0
    fi

    local base
    for base in /Applications "$HOME/Applications" /System/Applications /System/Library/CoreServices; do
        [ -d "$base" ] || continue

        while IFS= read -r -d '' app_path; do
            local plist current_id
            plist="${app_path}/Contents/Info.plist"
            [ -f "$plist" ] || continue

            current_id=$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$plist" 2>/dev/null || true)
            if [ "$current_id" = "$bundle_id" ]; then
                printf '%s\t%s\n' "$bundle_id" "$app_path" >>"$APP_INDEX_FILE"
                echo "$app_path"
                return 0
            fi
        done < <(find "$base" -maxdepth 3 -type d -name "*.app" -prune -print0 2>/dev/null)
    done

    return 1
}

icon_png_for_bundle_id() {
    local bundle_id=$1
    local out_png="${ICON_CACHE_DIR}/${bundle_id}.png"

    if [ -s "$out_png" ]; then
        echo "$out_png"
        return 0
    fi

    mkdir -p "$ICON_CACHE_DIR"

    local app_path plist
    app_path=$(app_path_for_bundle_id "$bundle_id" || true)
    if [ -z "${app_path:-}" ]; then
        return 1
    fi

    local icon_name icon_icns
    plist="${app_path}/Contents/Info.plist"
    icon_name=$(/usr/bin/plutil -extract CFBundleIconFile raw -o - "$plist" 2>/dev/null || true)
    if [ -n "$icon_name" ] && [[ "$icon_name" != *.icns ]]; then
        icon_name="${icon_name}.icns"
    fi

    if [ -n "$icon_name" ]; then
        icon_icns="${app_path}/Contents/Resources/${icon_name}"
    fi

    if [ -z "${icon_icns:-}" ] || [ ! -f "$icon_icns" ]; then
        icon_icns=$(find "${app_path}/Contents/Resources" -maxdepth 1 -name '*AppIcon*.icns' | head -n 1)
    fi

    if [ -z "${icon_icns:-}" ] || [ ! -f "$icon_icns" ]; then
        icon_icns=$(find "${app_path}/Contents/Resources" -maxdepth 1 -name '*.icns' | head -n 1)
    fi

    if [ -z "${icon_icns:-}" ] || [ ! -f "$icon_icns" ]; then
        return 1
    fi

    /usr/bin/sips -s format png -Z "$ICON_SIZE" "$icon_icns" --out "$out_png" >/dev/null 2>&1 || return 1

    echo "$out_png"
}

render_workspace_icon_strip() {
    local workspace_id=$1
    local key=$2
    shift 2
    local icons=("$@")

    mkdir -p "$WORKSPACE_ICON_DIR"

    local strip_png="${WORKSPACE_ICON_DIR}/workspace-${workspace_id}.png"
    local key_file="${WORKSPACE_ICON_DIR}/workspace-${workspace_id}.key"

    if [ -f "$strip_png" ] && [ -f "$key_file" ] && [ "$(cat "$key_file")" = "$key" ]; then
        echo "$strip_png"
        return 0
    fi

    local padded_width=$((ICON_SIZE + ICON_PADDING * 2))
    local padded_height=$ICON_SIZE

    local magick_bin="${MAGICK_BIN:-/opt/homebrew/bin/magick}"
    if [ ! -x "$magick_bin" ]; then
        magick_bin=$(command -v magick 2>/dev/null || true)
    fi
    if [ -z "$magick_bin" ]; then
        return 1
    fi

    local magick_args=()
    for icon in "${icons[@]}"; do
        magick_args+=("(" "$icon" -background none -gravity center -extent "${padded_width}x${padded_height}" ")")
    done

    "$magick_bin" "${magick_args[@]}" +append "$strip_png" >/dev/null 2>&1 || return 1
    printf '%s' "$key" >"$key_file"

    echo "$strip_png"
}

update_workspace_windows() {
    local workspace_id=$1

    apps=$(aerospace list-windows --workspace "$workspace_id" --format '%{app-bundle-id}|%{app-name}' 2>/dev/null)
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

    if [ "${apps}" != "" ]; then
        local bundle_ids=()
        local app_names=()
        local seen_key=" "

        while IFS='|' read -r bundle_id app_name; do
            [ -n "${bundle_id:-}" ] || continue

            if [[ "$seen_key" != *" $bundle_id "* ]]; then
                bundle_ids+=("$bundle_id")
                app_names+=("$app_name")
                seen_key+=" $bundle_id "
            fi
        done <<<"${apps}"

        local icon_paths=()
        local all_icons_available=true

        for bundle_id in "${bundle_ids[@]}"; do
            icon_path=$(icon_png_for_bundle_id "$bundle_id" || true)
            if [ -n "${icon_path:-}" ]; then
                icon_paths+=("$icon_path")
            else
                all_icons_available=false
                break
            fi
        done

        if [ "$all_icons_available" = "true" ] && [ "${#icon_paths[@]}" -gt 0 ]; then
            local key
            key=$(printf '%s\n' "${bundle_ids[@]}")

            strip_png=$(render_workspace_icon_strip "$workspace_id" "$key" "${icon_paths[@]}" || true)
            if [ -n "${strip_png:-}" ]; then
                local padded_width=$((ICON_SIZE + ICON_PADDING * 2))
                local strip_width=$((padded_width * ${#icon_paths[@]}))

                sketchybar --set space.$workspace_id \
                    label="" \
                    label.drawing=on \
                    label.width="$strip_width" \
                    label.background.color=0x0 \
                    label.background.corner_radius=0 \
                    label.background.height="$ICON_SIZE" \
                    label.background.image="$strip_png" \
                    label.background.image.drawing=on \
                    label.background.image.scale=1.0 \
                    label.background.drawing=on \
                    drawing=on
            else
                all_icons_available=false
            fi
        fi

        if [ "$all_icons_available" != "true" ]; then
            icon_strip=" "
            for app_name in "${app_names[@]}"; do
                __icon_map "$app_name"
                icon_strip+=" $icon_result"
            done

            sketchybar --set space.$workspace_id \
                label.background.drawing=off \
                label.background.image.drawing=off \
                label="$icon_strip" \
                label.drawing=on \
                label.width=dynamic \
                drawing=on
        fi

        if [ "$FOCUSED_WORKSPACE" = "$workspace_id" ]; then
            sketchybar --set space.$workspace_id background.drawing=on background.color=0xffcba6f7
        else
            sketchybar --set space.$workspace_id background.drawing=on background.color=0xff313244
        fi
    else
        if [ "$FOCUSED_WORKSPACE" = "$workspace_id" ]; then
            sketchybar --set space.$workspace_id \
                label.background.drawing=off \
                label.background.image.drawing=off \
                label.drawing=off \
                label.width=0 \
                background.drawing=on \
                background.color=0xffcba6f7 \
                drawing=on
        else
            sketchybar --set space.$workspace_id \
                label.background.drawing=off \
                label.background.image.drawing=off \
                label.drawing=off \
                label.width=0 \
                background.drawing=off \
                drawing=off
        fi
    fi
}

update_workspace_windows "$1"
