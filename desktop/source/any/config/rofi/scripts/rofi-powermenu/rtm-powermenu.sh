#! /bin/sh

chosen=$(printf "  Power Off\n  Restart\n  Lock" | rofi -dmenu -i -theme-str '@import "power.rasi"')

case "$chosen" in
        "  Power Off") poweroff ;;
        "  Restart") reboot ;;
        "  Lock") ~/.config/bspwm/scripts/blur-lock ;;
        *) exit 1 ;;
esac
