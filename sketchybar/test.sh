#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
sid=12
RED=0xffed8796

  sketchybar --add space      space.$sid left                               \
             --set space.$sid associated_space=$sid                         \
                              icon="6" \
                              icon.padding_left=22                          \
                              icon.padding_right=22                         \
                              label.padding_right=33                        \
                              icon.highlight_color=$RED                     \
                              background.height=30                          \
                              background.corner_radius=9                    \
                              background.color=0xff3C3E4F                   \
                              background.drawing=off                         \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.background.height=30                    \
                              label.background.drawing=on                   \
                              label.background.color=0xff494d64             \
                              label.background.corner_radius=9              \
                              label.drawing=off                             \
        click_script="aerospace workspace $sid" \
        script="/Users/omerxx/dotfiles/sketchybar/plugins/aerospacer.sh $sid"
