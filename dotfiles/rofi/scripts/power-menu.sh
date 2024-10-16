#!/bin/bash

# Options for the power menu
OPTIONS="Shutdown\nRestart\nCancel"

# Show options in Rofi and capture the selection
SELECTED_OPTION=$(echo -e "$OPTIONS" | rofi -dmenu -p "Power Menu" -i -theme Arc-Dark -lines 3 -theme-str "window { width: 15%; } listview { lines: 3; }")

# Execute the selected option
case $SELECTED_OPTION in
Shutdown)
	systemctl poweroff
	;;
Restart)
	systemctl reboot
	;;
Cancel)
	exit 0
	;;
*)
	exit 1
	;;
esac
