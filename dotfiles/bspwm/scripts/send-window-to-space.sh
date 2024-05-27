#!/bin/bash

# Get the list of all spaces
spaces=$(bspc query -D --names)

# Get the ID of the focused window
focused_window=$(bspc query -N -n focused)

# Check if there is a focused window
if [ -z "$focused_window" ]; then
    echo "No focused window."
    exit 1
fi

# Get the current space of the focused window
current_space=$(bspc query -D -d focused --names)

# Annotate the current space in the list of spaces
annotated_spaces=$(echo "$spaces" | sed "s/^$current_space\$/$current_space (current)/")

# Use rofi to select a space
selected_space=$(echo "$annotated_spaces" | rofi -theme menu.rasi -dmenu -p "Select space:" | sed 's/ (current)//')

# Check if a space was selected
if [ -z "$selected_space" ]; then
    echo "No space selected."
    exit 1
fi

# Move the focused window to the selected space
bspc node "$focused_window" --to-desktop "$selected_space"

echo "Moved window $focused_window to space $selected_space."

