#!/bin/bash
# Select DEB or RPM system
gnome_check=`env |grep XDG_CURRENT_DESKTOP |grep -ioh "GNOME" | awk '{print tolower($0)}'`
kde_check=`env |grep XDG_CURRENT_DESKTOP |grep -ioh "KDE" | awk '{print tolower($0)}'`

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

if check_cmd apt-get; then # FOR DEB SYSTEMS
    if [[ $gnome_check == "gnome" ]]; then
    bash desktop/0-DEB/0-gnome-system.sh
    elif [[ $kde_check == "kde" ]]; then
    bash desktop/0-DEB/0-kde-system.sh
    else
    echo "Not able to identify desktop environment"
    fi
elif check_cmd dnf; then  # FOR RPM SYSTEMS
     bash desktop/1-RPM/0-system.sh
else
    echo "Not able to identify the system"
fi