#!/bin/bash

# Define options for each key
declare -A options
options["a"]="à\ná\nâ\nã\nä\nª\nÀ\nÁ\nÂ\nÃ\nÄ"
options["e"]="è\né\nê\në\nÈ\nÉ\nÊ\nË"
options["i"]="ì\ní\nî\nï\nÌ\nÍ\nÎ\nÏ"
options["o"]="ò\nó\nô\nõ\nö\nº\nÒ\nÓ\nÔ\nÕ\nÖ"
options["u"]="ù\nú\nû\nü\nÙ\nÚ\nÛ\nÜ"
options["c"]="ç\n©\nĉ\nÇ\nĈ"
options["n"]="ñ\nń\nÑ\nŃ"
options["s"]="ß\nẞ"

# Show Rofi menu to select a key
key=$(printf "%s\n" "${!options[@]}" | rofi -dmenu -p "Select Key" -theme menu.rasi)

# Check if a key was selected and has options
if [ -n "$key" ] && [ -n "${options[$key]}" ]; then
	# Show Rofi menu with options for the selected key
	option=$(echo -e "${options[$key]}" | rofi -dmenu -p "Select Option for $key" -theme menu.rasi)

	# Copy and type the selected option
	if [ -n "$option" ]; then
		# Copy to clipboard
		if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
			echo -n "$option" | wl-copy
		elif command -v xclip >/dev/null 2>&1; then
			echo -n "$option" | xclip -selection clipboard
		fi

		# Sleep briefly to allow focus to return to the active window after Rofi closes
		sleep 0.2

		# Type the option
		if [ -n "$WAYLAND_DISPLAY" ] && command -v wtype >/dev/null 2>&1; then
			wtype "$option"
		elif command -v xdotool >/dev/null 2>&1; then
			xdotool type "$option"
		fi
	fi
fi
