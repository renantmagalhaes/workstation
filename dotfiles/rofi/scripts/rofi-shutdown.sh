#!/bin/bash
# Rofi Shutdown Screen
# Author: Renan Toesqui Magalhães

echo -e "Yes\nNo" | rofi -dmenu -i -p "Shutdown?" -theme Arc-Dark -lines 2 -theme-str "window { width: 10%; } listview { lines: 2; }" | grep -q Yes && systemctl poweroff
