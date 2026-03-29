#!/usr/bin/env bash
# Rofi Logout Screen
# Author: Renan Toesqui Magalhães

dir="$HOME/.config/rofi/scripts/powermenu/type-2"
theme='style-5'

# Options
yes=' Yes'
no=' No'

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you sure you want to Logout?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
selected="$(echo -e "$yes\n$no" | confirm_cmd)"

if [[ "$selected" == "$yes" ]]; then
	if command -v hyprctl >/dev/null 2>&1; then
		hyprctl dispatch exit
	elif command -v bspc >/dev/null 2>&1; then
		bspc quit
	else
		loginctl terminate-session $XDG_SESSION_ID
	fi
else
	exit 0
fi
