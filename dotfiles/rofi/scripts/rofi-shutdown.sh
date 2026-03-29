#!/usr/bin/env bash
# Rofi Shutdown Screen
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
		-mesg 'Are you sure you want to Shutdown?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
selected="$(echo -e "$yes\n$no" | confirm_cmd)"

if [[ "$selected" == "$yes" ]]; then
	systemctl poweroff
else
	exit 0
fi
