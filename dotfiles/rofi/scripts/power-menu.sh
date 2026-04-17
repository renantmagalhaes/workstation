#!/bin/bash

is_gnome() { [ "$DESKTOP_SESSION" = "gnome" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; }
is_kde()   { [ "$DESKTOP_SESSION" = "plasma" ] || [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; }

if is_gnome; then
    SELECTED_OPTION=$(zenity --list \
        --title="Power Menu" \
        --column="Option" \
        "Shutdown" "Restart" "Cancel" \
        --height=200 2>/dev/null)
elif is_kde; then
    SELECTED_OPTION=$(kdialog --menu "Power Menu" \
        "Shutdown" "Shutdown" \
        "Restart" "Restart" \
        "Cancel" "Cancel" 2>/dev/null)
else
    SELECTED_OPTION=$(echo -e "Shutdown\nRestart\nCancel" | rofi -dmenu -p "Power Menu" -i \
        -theme Arc-Dark -lines 3 \
        -theme-str "window { width: 15%; } listview { lines: 3; }")
fi

case $SELECTED_OPTION in
    Shutdown) systemctl poweroff ;;
    Restart)  systemctl reboot ;;
    Cancel)   exit 0 ;;
    *)        exit 1 ;;
esac
