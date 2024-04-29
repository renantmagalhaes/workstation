#!/bin/bash
# Select DEB or RPM system
gnome_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "GNOME" | awk '{print tolower($0)}')
kde_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "KDE" | awk '{print tolower($0)}')
macos_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')
linux_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

if check_cmd explorer.exe; then # FOR WSL SYSTEMS
	if check_cmd apt-get; then
		bash ./OperatingSystem/wsl-deb.sh
	elif check_cmd zypper; then
		bash ./OperatingSystem/wsl-zypper.sh
	else
		echo "Not able to identify desktop environment"
	fi
elif check_cmd apt-get; then # FOR DEB SYSTEMS
	if [[ $gnome_check == "gnome" ]]; then
		bash ./OperatingSystem/0-debian-gnome-system.sh
	elif [[ $kde_check == "kde" ]]; then
		echo "KDE not supported"
	else
		echo "Not able to identify desktop environment"
	fi
elif check_cmd dnf; then # FOR RPM SYSTEMS
	echo "System not supported"
elif check_cmd zypper; then # FOR OPENSUSE SYSTEMS
	if [[ $gnome_check == "gnome" ]]; then
		bash ./OperatingSystem/2-opensuse-gnome-system.sh
	elif [[ $kde_check == "kde" ]]; then
		echo "KDE not supported"
	else
		echo "Not able to identify desktop environment"
	fi
elif check_cmd pacman; then # FOR ARCH SYSTEMS
	echo "System not supported"
elif check_cmd sw_vers; then # FOR MACOS SYSTEMS
	if [[ $macos_check == "darwin" ]]; then
		bash ./OperatingSystem/macos.sh
	else
		echo "Not able to identify desktop environment"
	fi
fi
