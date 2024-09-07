#!/bin/bash

# If no argument is provided, show options
if [ -z "$1" ]; then
    # This output will show in the Rofi combi search as a valid mode
    echo -e "Shutdown\nRestart\nCancel"
else
    case $1 in
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
fi

