#!/usr/bin/env bash

dir="$HOME/.config/rofi/scripts/launchers/type-1"
theme='style-7'

# Get list of running processes for the current user, excluding common system/script names
PROCESS_LIST=$(ps -u "$USER" -o comm= | grep -vE "kill.sh|ps|grep|sort|sed|awk|sh|bash" | sort -u)

# Prepare list for Rofi
# We'll clean up common process suffixes to help Rofi find the correct icon
ROFI_INPUT=""
while read -r comm; do
    [ -z "$comm" ] && continue
    
    # Try to find a better icon name by stripping common suffixes
    icon="${comm%-bin}"
    icon="${icon%_bin}"
    icon="${icon%-wrapped}"
    icon="${icon%.real}"
    icon="${icon#python-}" # handles some script wrappers
    icon="${icon,,}" # lowercase
    
    # Special cases
    if [[ "$comm" == "code" ]]; then icon="visual-studio-code"; fi
    
    ROFI_INPUT+="${comm}\0icon\x1f${icon}\n"
done <<< "$PROCESS_LIST"

# Show the process list in Rofi for selection
SELECTED_PROCESS=$(echo -ne "$ROFI_INPUT" | rofi -dmenu -p "kill" -i -show-icons -theme ${dir}/${theme}.rasi)

# If a process is selected, kill all its instances
if [ -n "$SELECTED_PROCESS" ]; then
    pkill -u "$USER" "$SELECTED_PROCESS"
fi
