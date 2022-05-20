#!/bin/bash

numberOfDesktops=$(wmctrl -d | wc -l)
lastdesktop=$((wmctrl -d |tail -n 1|awk '{print $1}' + 1))
currentDesktop=$(qdbus org.kde.KWin /KWin currentDesktop)
nextDesktop=$((currentDesktop + 1))

if [[ $currentDesktop = $lastdesktop ]]; then
    exit
elif [[ $currentDesktop = "$numberOfDesktops" ]]; then
    qdbus org.kde.KWin /KWin setCurrentDesktop 1
else
    qdbus org.kde.KWin /KWin setCurrentDesktop $nextDesktop
fi


mon=`bspc query -D -d focused --names` && bspc desktop --focus $((mon + 1))