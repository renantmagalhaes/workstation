#!/usr/bin/env bash
# Rofi Logout Screen
# Author: Renan Toesqui Magalhães

is_gnome() { [ "$DESKTOP_SESSION" = "gnome" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; }
is_kde()   { [ "$DESKTOP_SESSION" = "plasma" ] || [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; }

if is_gnome; then
    gnome-session-quit --logout
    exit 0
fi

if is_kde; then
    qdbus "org.kde.ksmserver" "/KSMServer" "logout" "1" "0" "2"
    exit 0
fi

dir="$HOME/.config/rofi/scripts/powermenu/type-2"
theme='style-5'

yes=' Yes'
no=' No'

confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure you want to Logout?' \
        -theme "${dir}/${theme}.rasi"
}

selected="$(echo -e "$yes\n$no" | confirm_cmd)"
if [[ "$selected" == "$yes" ]]; then
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl dispatch exit
    elif command -v bspc >/dev/null 2>&1; then
        bspc quit
    else
        loginctl terminate-session "$XDG_SESSION_ID"
    fi
fi
