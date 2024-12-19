#!/bin/bash
#wmctrl -l | awk '{print $1, substr($0, index($0, $4))}' | rofi -dmenu -p "Open Windows" -theme Arc-Dark -matching fuzzy | awk '{print $1}' | xargs -I {} wmctrl -ia {}
rofi -show window -theme menu.rasi -matching fuzzy
