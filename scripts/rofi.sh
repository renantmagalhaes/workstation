#!/bin/bash

# Get current folder
FOLDER_LOCATION=$(pwd)

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS

	# sudo apt-get install -y rofi
	sudo apt-get install -y flex libxkbcommon-dev libxkbcommon-x11-dev libxcb-cursor-dev libxcb-xinerama0-dev libstartup-notification0-dev check bison meson libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev
	ROFI_RELEASE=1.7.5
	rofi_script_path=$(pwd)
	wget https://github.com/davatorium/rofi/releases/download/$ROFI_RELEASE/rofi-$ROFI_RELEASE.tar.gz -O ~/GIT-REPOS/CORE/rofi.tar.gz
	cd ~/GIT-REPOS/CORE/ && tar -xvf rofi.tar.gz && cd rofi-$ROFI_RELEASE
	mkdir -p build && cd build
	../configure
	make
	sudo make install
	cd $rofi_script_path

	#XCAPE - Bind rofi to SuperKey
	sudo apt-get install -y git gcc make pkg-config libx11-dev libxtst-dev libxi-dev

elif check_cmd zypper; then # FOR RPM SYSTEMS
	sudo zypper install -y rofi

	#XCAPE - Bind rofi to SuperKey
	sudo zypper install -y git gcc make pkgconfig libX11-devel libXtst-devel libXi-devel

else
	echo "Not able to identify the system"
	exit 0
fi

# Folders
mkdir -p ~/.local/share/rofi/themes/

# Rofi config
git clone https://github.com/lr-tech/rofi-themes-collection.git ~/GIT-REPOS/CORE/rofi-themes-collection
cp -r ~/GIT-REPOS/CORE/rofi-themes-collection/themes/* ~/.local/share/rofi/themes/
# ln -s -f $PWD/config/rofi/rtm-rofi-theme.rasi ~/.config/rofi/rtm-rofi-theme.rasi
# ln -s -f $PWD/config/rofi/config.rasi ~/.config/rofi/config.rasi
rm -rf ~/.config/rofi
cd $FOLDER_LOCATION
ln -s -f $PWD/dotfiles/rofi/ ~/.config/

#XCAPE - Bind rofi to SuperKey
git clone https://github.com/alols/xcape.git ~/GIT-REPOS/CORE/xcape
cd ~/GIT-REPOS/CORE/xcape
make
sudo make install

# XCAPE syslink to autostart
mkdir -p ~/.config/autostart/
# ln -s -f ~/.config/rofi/scripts/xcape.desktop ~/.config/autostart/xcape.desktop

# Desktop files to system operations
# Create the kill.desktop file
cat <<EOF > ~/.local/share/applications/kill.desktop
[Desktop Entry]
Name=Kill Process
Exec=/home/rtm/.config/rofi/scripts/kill.sh
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;
EOF

# Create the power-menu.desktop file
cat <<EOF > ~/.local/share/applications/power-menu.desktop
[Desktop Entry]
Name=Power Menu
Exec=/home/rtm/.config/rofi/scripts/power-menu.sh
Icon=system-shutdown
Terminal=false
Type=Application
Categories=System;
EOF

# Refresh the desktop database to pick up the new entries
update-desktop-database ~/.local/share/applications

# Notify user
echo "Desktop entry files created and desktop database updated."

