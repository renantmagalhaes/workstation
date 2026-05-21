#!/bin/bash

# Get active monitor in MangoWM
active_monitor=$(mmsg -g | awk '$2=="selmon" && $3=="1" {print $1}')
if [ -z "$active_monitor" ]; then
    echo "No active monitor."
    exit 1
fi

# Get current tag on the active monitor
current_tag=$(mmsg -g | awk -v mon="$active_monitor" '$1==mon && $2=="tag" && $4=="1" {print $3; exit}')

# Show only 1-5 for selection
spaces=$(seq 1 5)

if [ -n "$current_tag" ]; then
    annotated_spaces=$(echo "$spaces" | sed "s/^$current_tag\$/$current_tag (current)/")
else
    annotated_spaces="$spaces"
fi

selected_tag=$(echo "$annotated_spaces" | rofi -theme menu.rasi -dmenu -p "Select tag:" | sed 's/ (current)//')

if [ -z "$selected_tag" ]; then
    echo "No tag selected."
    exit 1
fi

if ! [[ "$selected_tag" =~ ^[1-5]$ ]]; then
    echo "Invalid tag selected: $selected_tag"
    exit 1
fi

mmsg -d tag,"$selected_tag",0
echo "Moved window to tag $selected_tag on monitor $active_monitor."
