#!/usr/bin/env bash

dir="$HOME/.config/rofi/scripts/launchers/type-1"
theme='style-7'

PROCESS_LIST=$(ps -u "$USER" -o comm= | grep -vE "kill.sh|ps|grep|sort|sed|awk|sh|bash" | sort -u)

is_gnome() { [ "$DESKTOP_SESSION" = "gnome" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; }
is_kde()   { [ "$DESKTOP_SESSION" = "plasma" ] || [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; }

if is_gnome; then
    SELECTED_PROCESS=$(echo "$PROCESS_LIST" | zenity --list \
        --title="Kill Process" \
        --column="Process" \
        --height=500 2>/dev/null)
elif is_kde; then
    SELECTED_PROCESS=$(echo "$PROCESS_LIST" | tr '\n' ' ' | \
        xargs kdialog --combobox "Select process to kill" 2>/dev/null)
else
    ROFI_INPUT=""
    while read -r comm; do
        [ -z "$comm" ] && continue
        icon="${comm%-bin}"
        icon="${icon%_bin}"
        icon="${icon%-wrapped}"
        icon="${icon%.real}"
        icon="${icon#python-}"
        icon="${icon,,}"
        if [[ "$comm" == "code" ]]; then icon="visual-studio-code"; fi
        ROFI_INPUT+="${comm}\0icon\x1f${icon}\n"
    done <<< "$PROCESS_LIST"
    SELECTED_PROCESS=$(echo -ne "$ROFI_INPUT" | rofi -dmenu -p "kill" -i -show-icons -theme ${dir}/${theme}.rasi)
fi

if [ -n "$SELECTED_PROCESS" ]; then
    pkill -u "$USER" "$SELECTED_PROCESS"
fi
