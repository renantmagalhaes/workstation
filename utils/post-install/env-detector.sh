#!/bin/bash 

gnome_check=`env |grep XDG_CURRENT_DESKTOP |grep -ioh "GNOME" | awk '{print tolower($0)}'`
kde_check=`env |grep XDG_CURRENT_DESKTOP |grep -ioh "KDE" | awk '{print tolower($0)}'`


if [[ $gnome_check == "gnome" ]]; then
    vi utils/post-install/gnome.md
elif [[ $kde_check == "kde" ]]; then
    vi utils/post-install/kde.md
else
echo "Not able to identify desktop environment"
fi