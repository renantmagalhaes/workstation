#!/bin/bash
# Rofi Restart Screen
# Author: Renan Toesqui Magalhães

echo -e "Yes\nNo" | rofi -dmenu -i -p "Restart?" -theme Arc-Dark -lines 2 -theme-str "window { width: 10%; } listview { lines: 2; }" | grep -q Yes && systemctl reboot
