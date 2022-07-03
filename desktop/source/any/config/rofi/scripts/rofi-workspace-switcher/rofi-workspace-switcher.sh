#!/bin/bash

#TODO
#// find number of workspaces on primary monitor
# multiply the icon * number the worspaces (1 monitor)
# loop in a list with a counter and print the icons of the worspaces. if workspace == get_current_workspace print full icon, else print empty icon
# change the icon from the current workspace



GET_TOTAL_NUM_WORKSPACES=`bspc query -D  --names |wc -l`
GET_TOTAL_NUM_MONITORS=`xrandr --listactivemonitors |wc -l`


GET_CURRENT_WORKSPACE=`bspc query -D -d focused --names`
NUM_WORKSPACES=$((GET_TOTAL_NUM_WORKSPACES / (GET_TOTAL_NUM_MONITORS - 1)))



echo "    "
echo "    "