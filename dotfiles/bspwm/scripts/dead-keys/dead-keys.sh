#!/bin/bash

# Define options for each key
declare -A options
options["a"]="à\ná\nâ\nã\nä"
options["e"]="è\né\nê\në"
options["i"]="ì\ní\nî\nï"
options["o"]="ò\nó\nô\nõ\nö"
options["u"]="ù\nú\nû\nü"
options["c"]="ç\n©\nĉ"
options["n"]="ñ\nń"

# Show Rofi menu to select a key
key=$(printf "%s\n" "${!options[@]}" | rofi -dmenu -p "Select Key" -theme menu.rasi)

# Check if a key was selected and has options
if [ -n "$key" ] && [ -n "${options[$key]}" ]; then
	# Show Rofi menu with options for the selected key
	option=$(echo -e "${options[$key]}" | rofi -dmenu -p "Select Option for $key" -theme menu.rasi)

	# Type the selected option
	if [ -n "$option" ]; then
		xdotool type "$option"
	fi
fi
