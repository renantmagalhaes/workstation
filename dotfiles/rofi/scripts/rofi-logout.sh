#!/bin/bash
# Rofi Logout Screen
# Author: Renan Toesqui Magalhães

# Support for Hyprland, BSPWM and fallback to generic loginctl
echo -e "Yes\nNo" | rofi -dmenu -i -p "Logout?" -theme Arc-Dark -lines 2 -theme-str "window { width: 10%; } listview { lines: 2; }" | grep -q Yes && {
	if command -v hyprctl >/dev/null 2>&1; then
		hyprctl dispatch exit
	elif command -v bspc >/dev/null 2>&1; then
		bspc quit
	else
		loginctl terminate-session $XDG_SESSION_ID
	fi
}
