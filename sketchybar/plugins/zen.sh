#!/bin/sh

if [ $1 = "on" ]; then
  sketchybar --set github.bell drawing=off \
             --set apple.logo drawing=off \
             --set '/cpu.*/' drawing=off \
             --set calendar icon.drawing=off \
             --set system.yabai drawing=off \
             --set separator drawing=off \
             --set front_app drawing=off \
             --set spotify.play updates=off \
             --set spotify.title drawing=off \
             --set spotify.artist drawing=off
else
  sketchybar --set github.bell drawing=on \
             --set apple.logo drawing=on \
             --set '/cpu.*/' drawing=on \
             --set calendar icon.drawing=on \
             --set separator drawing=on \
             --set front_app drawing=on \
             --set system.yabai drawing=on \
             --set spotify.play updates=on
fi

