#!/usr/bin/env bash

dir="$HOME/.config/rofi/scripts/launchers/type-1"
theme='style-7'

# Get list of running processes for the current user, excluding common system/script names
PROCESS_LIST=$(ps -u "$USER" -o comm= | grep -vE "kill.sh|ps|grep|sort|sed|awk|sh|bash" | sort -u)

# Prepare list for Rofi
# We just pass the name as the icon name. Rofi will find it if it exists in the current icon theme.
# This is O(n) and very fast compared to searching desktop files.
ROFI_INPUT=""
while read -r comm; do
    [ -z "$comm" ] && continue
    ROFI_INPUT+="${comm}\0icon\x1f${comm}\n"
done <<< "$PROCESS_LIST"

# Show the process list in Rofi for selection
SELECTED_PROCESS=$(echo -ne "$ROFI_INPUT" | rofi -dmenu -p "kill" -i -show-icons -theme ${dir}/${theme}.rasi)

# If a process is selected, kill all its instances
if [ -n "$SELECTED_PROCESS" ]; then
    pkill -u "$USER" "$SELECTED_PROCESS"
fi
