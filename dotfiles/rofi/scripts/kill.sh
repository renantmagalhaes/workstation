#!/bin/bash

# List all running processes by their name (excluding duplicates)
PROCESS_LIST=$(ps -e -o comm= | sort -u)

# Show the process list in Rofi for selection
SELECTED_PROCESS=$(echo "$PROCESS_LIST" | rofi -dmenu -p "kill" -i --show-icons --theme menu.rasi)

# If a process is selected, kill all its instances
if [ -n "$SELECTED_PROCESS" ]; then
    pkill "$SELECTED_PROCESS"
fi
