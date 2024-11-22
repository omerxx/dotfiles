#!/usr/bin/env sh

sketchybar --add       item            github.bell right                  \
           --set       github.bell     update_freq=180                    \
                                       icon.font="$FONT:Bold:15.0"        \
                                       icon=$BELL                         \
                                       icon.color=$BLUE                   \
                                       label=$LOADING                     \
                                       label.highlight_color=$BLUE        \
                                       background.padding_left=10         \
                                       popup.align=right                  \
                                       script="$PLUGIN_DIR/github.sh"     \
                                       click_script="$POPUP_CLICK_SCRIPT" \
           --subscribe github.bell     mouse.entered                      \
                                       mouse.exited                       \
                                       mouse.exited.global                \
                                                                          \
           --add       item            github.template popup.github.bell  \
           --set       github.template drawing=off                        \
                                       background.corner_radius=12        \
                                       background.padding_left=7          \
                                       background.padding_right=7         \
                                       background.color=$BLACK            \
                                       background.drawing=off             \
                                       icon.background.height=2           \
                                       icon.background.y_offset=-12
