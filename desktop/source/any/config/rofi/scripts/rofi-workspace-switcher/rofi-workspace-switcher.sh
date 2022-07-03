#!/bin/bash

#TODO
#// find number of workspaces on primary monitor
# multiply the icon * number the worspaces (1 monitor)
# loop in a list with a counter and print the icons of the worspaces. if workspace == get_current_workspace print full icon, else print empty icon
# change the icon from the current workspace

# echo "    "
# echo "    "
# echo "    "
# echo "    "
# echo "    "
# echo "    "
# echo "    "

# ~/GIT-REPOS/workstation/desktop/source/any/config/rofi/scripts/rofi-workspace-switcher/rofi-workspace-switcher.sh | rofi -dmenu

GET_TOTAL_NUM_WORKSPACES=`bspc query -D  --names |wc -l`
GET_TOTAL_NUM_MONITORS=`xrandr --listactivemonitors |wc -l`


GET_CURRENT_WORKSPACE=`bspc query -D -d focused --names`
NUM_WORKSPACES=$((GET_TOTAL_NUM_WORKSPACES / (GET_TOTAL_NUM_MONITORS - 1)))

if [[ $GET_CURRENT_WORKSPACE == 1 ]] || [[ $GET_CURRENT_WORKSPACE == 11 ]]
then
    echo "    "
elif [[ $GET_CURRENT_WORKSPACE == 2 ]] || [[ $GET_CURRENT_WORKSPACE == 22 ]]
then
    echo "    "
elif [[ $GET_CURRENT_WORKSPACE == 3 ]] || [[ $GET_CURRENT_WORKSPACE == 33 ]]
then
    echo "    "
elif [[ $GET_CURRENT_WORKSPACE == 4 ]] || [[ $GET_CURRENT_WORKSPACE == 44 ]]
then
    echo "    "
elif [[ $GET_CURRENT_WORKSPACE == 5 ]] || [[ $GET_CURRENT_WORKSPACE == 55 ]]
then
    echo "    "
fi


