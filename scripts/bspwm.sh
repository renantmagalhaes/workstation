#!/bin/bash

# Get current folder
FOLDER_LOCATION=$(pwd)

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
	sudo apt-get install -y bspwm sxhkd feh lxappearance playerctl x11-xserver-utils nitrogen scrot xdotool network-manager lm-sensors playerctl i3lock papirus-icon-theme pavucontrol jgmenu mate-polkit mate-polkit-bin libnotify-bin qt5ct kdeconnect nautilus-kdeconnect x11-utils gnome-calendar nautilus
	sudo apt-get install -y blueman pasystray
	sudo pip3 install pywal --break-system-packages

	# Dunst
	sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk2.0-dev libxdg-basedir-dev libnotify-dev xdg-utils libwayland-client0
	git clone https://github.com/dunst-project/dunst.git ~/GIT-REPOS/CORE/dunst
	cd ~/GIT-REPOS/CORE/dunst
	sudo it config --global --add safe.directory ~/GIT-REPOS/CORE/dunst
	make -j5 WAYLAND=0
	sudo make WAYLAND=0 install

	# Picom
	sudo apt-get install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev cmake
	git clone https://github.com/yshui/picom.git ~/GIT-REPOS/CORE/picom
	cd ~/GIT-REPOS/CORE/picom
	meson --buildtype=release . build
	ninja -C build
	sudo ninja -C build install

	# # Auto-update repo
	# sudo cp ./dotfiles/bspwm/systemd-service/apt-update.service /etc/systemd/system/apt-update.service
	# sudo cp ./dotfiles/bspwm/systemd-service/apt-update.timer /etc/systemd/system/apt-update.timer
	# sudo systemctl enable --now apt-update.timer

elif check_cmd zypper; then # FOR RPM SYSTEMS

	# Install dependencies
	sudo zypper install -y bspwm sxhkd feh lxappearance playerctl blueman xsetroot dunst nitrogen scrot xdotool NetworkManager-applet pcp-pmda-lmsensors playerctl i3lock papirus-icon-theme pasystray pavucontrol jgmenu mate-polkit libnotify4 libnotify-devel libnotify-tools xprop xwininfo gnome-calendar xdpyinfo
	sudo pip3 install pywal --break-system-packages

	# # Dunst
	# sudo zypper in -y libxdg-basedir-devel libX11-devel libXinerama-devel libXrandr-devel libXScrnSaver-devel glib2-devel pango-devel dbus-1-devel libnotify-devel gcc make
	# git clone https://github.com/dunst-project/dunst.git ~/GIT-REPOS/CORE/dunst
	# cd ~/GIT-REPOS/CORE/dunst
	# sudo it config --global --add safe.directory ~/GIT-REPOS/CORE/dunst
	# make -j5 WAYLAND=0
	# sudo make WAYLAND=0 install

	# Picom
	sudo zypper install -y dbus-1-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb1 libXext-devel libxcb-devel Mesa-libGL-devel meson pcre2-devel libpixman-1-0-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorgproto-devel libepoxy-devel Mesa-libEGL-devel xcb-util-devel nautilus
	git clone https://github.com/yshui/picom.git ~/GIT-REPOS/CORE/picom
	cd ~/GIT-REPOS/CORE/picom
	meson --buildtype=release . build
	ninja -C build
	sudo ninja -C build install
	# YAD
	echo "Updating system and installing necessary build tools..."
	sudo zypper install -y git autoconf automake gtk3-devel intltool pkg-config
	echo "Cloning YAD repository..."
	git clone https://github.com/v1cont/yad.git ~/GIT-REPOS/CORE/yad
	cd ~/GIT-REPOS/CORE/yad
	# Generate configuration scripts using autogen.sh
	echo "Generating configuration scripts..."
	autoreconf -ivf && intltoolize
	# Configure the build
	echo "Configuring the build environment..."
	./configure
	echo "Compiling YAD..."
	make
	echo "Installing YAD..."
	sudo make install

else
	echo "Not able to identify the system"
	exit 0
fi

# Create folders
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi ~/.local/share/rofi/themes/ ~/.config/alacritty/ ~/.config/dunst/
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/

# xqp
git clone https://github.com/baskerville/xqp.git ~/GIT-REPOS/CORE/xqp
cd ~/GIT-REPOS/CORE/xqp
make
sudo make install

# tddrop
git clone https://github.com/noctuid/tdrop.git ~/GIT-REPOS/CORE/tdrop
cd ~/GIT-REPOS/CORE/tdrop
sudo make install

## BSPWM
cd $FOLDER_LOCATION
rm -rf ~/.config/bspwm ~/.config/sxhkd/
mkdir -p ~/.config/sxhkd/
ln -s -f $PWD/dotfiles/bspwm ~/.config/
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/dotfiles/bspwm/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc

# scripts
ln -s -f $PWD/dotfiles/bspwm/scripts ~/.config/bspwm/

# Picom config
ln -s -f $PWD/dotfiles/bspwm/picom/picom.conf ~/.config/picom/picom.conf

# Dunst config
rm -rf ~/.config/dunst
ln -s -f $PWD/dotfiles/bspwm/dunst ~/.config/

# Nitrogen config
rm -rf ~/.config/nitrogen
ln -s -f $PWD/dotfiles/bspwm/nitrogen ~/.config/

# jgmenu config
#rm -rf ~/.config/jgmenu/
ln -s -f $PWD/dotfiles/bspwm/jgmenu ~/.config/

# Themes GTK
## Create files if not exist
mkdir -p ~/.config/gtk-3.0
touch ~/.config/gtk-3.0/settings.ini
mkdir -p ~/.config/gtk-4.0
touch ~/.config/gtk-4.0/settings.ini
## Backup files
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.bkp
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.bkp
## dump config
bash -c 'cat << EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=0
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-blue
EOF'
bash -c 'cat << EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=0
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-blue
EOF'

echo "export GTK_THEME=Graphite-Dark" >>~/.profile
echo "export GTK_THEME=Graphite-Dark" >>~/.zprofile
