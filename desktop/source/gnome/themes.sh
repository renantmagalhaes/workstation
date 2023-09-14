#!/bin/sh
#
#
#?Site        :https://rtm.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#
# ---------------------------------------------------------------
#
# This script  will install all the theme packages for Gnome DE
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2022-01-01 RTM:
#       - Initial release
#
# TODO:

# Nordic theme
git clone https://github.com/EliverLara/Nordic.git ~/GIT-REPOS/CORE/Nordic
sudo mv ~/GIT-REPOS/CORE/Nordic /usr/share/themes/

# Qogir theme
git clone https://github.com/vinceliuice/Qogir-theme.git ~/GIT-REPOS/CORE/Qogir-theme
sh -c "~/GIT-REPOS/CORE/Qogir-theme/install.sh"

# Orchis theme
git clone https://github.com/vinceliuice/Orchis-theme.git ~/GIT-REPOS/CORE/Orchis-theme
sh -c "~/GIT-REPOS/CORE/Orchis-theme/install.sh"

# ChromeOS theme
# git clone https://github.com/vinceliuice/ChromeOS-theme.git ~/GIT-REPOS/CORE/ChromeOS-theme
# sh -c "~/GIT-REPOS/CORE/ChromeOS-theme/install.sh"

# WhiteSur-gtk-theme
# git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ~/GIT-REPOS/CORE/WhiteSur-gtk-theme
# sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/install.sh -i void -N mojave -c dark -c light -t all 

# Fluent Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git ~/GIT-REPOS/CORE/Fluent-gtk-theme
sh -c "~/GIT-REPOS/CORE/Fluent-gtk-theme/install.sh --tweaks float solid"

git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/GIT-REPOS/CORE/Fluent-icon-theme
sh -c "~/GIT-REPOS/CORE/Fluent-icon-theme/install.sh"
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist /usr/share/icons/Fluent-cursors
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist-dark /usr/share/icons/Fluent-dark-cursors

# Dracula theme
wget https://github.com/dracula/gtk/archive/master.zip -O ~/.themes/Dracula.zip
unzip ~/.themes/Dracula.zip -d ~/.themes/Dracula
mv ~/.themes/Dracula/gtk-master/* ~/.themes/Dracula

# Matcha Theme
git clone https://github.com/vinceliuice/Matcha-gtk-theme.git ~/GIT-REPOS/CORE/Matcha-gtk-theme
sh -c "~/GIT-REPOS/CORE/Matcha-gtk-theme/install.sh"


# Graphite-gtk-theme
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git ~/GIT-REPOS/CORE/Graphite-gtk-theme
sh -c "~/GIT-REPOS/CORE/Graphite-gtk-theme/install.sh --tweaks black normal rimless"
# sh -c "~/GIT-REPOS/CORE/Graphite-gtk-theme/install.sh --tweaks black normal"
# sh -c "~/GIT-REPOS/CORE/Graphite-gtk-theme/install.sh --tweaks nord"

# Colloid-gtk-theme
git clone https://github.com/vinceliuice/Colloid-gtk-theme.git ~/GIT-REPOS/CORE/Colloid-gtk-theme
cd  ~/GIT-REPOS/CORE/Colloid-gtk-theme && sh -c "./install.sh --tweaks --tweaks dracula"


# Jasper-gtk-theme
git clone https://github.com/vinceliuice/Jasper-gtk-theme.git ~/GIT-REPOS/CORE/Jasper-gtk-theme
sh -c "~/GIT-REPOS/CORE/Jasper-gtk-theme/install.sh -t grey --tweaks nord"
sh -c "~/GIT-REPOS/CORE/Jasper-gtk-theme/install.sh -t grey --tweaks black"
sh -c "~/GIT-REPOS/CORE/Jasper-gtk-theme/install.sh -t grey --tweaks dracula"

##############################################
# ICONS

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh blue -c nord"
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh dracula"
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh purple"

# Tela-icon-theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/CORE/Tela-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-icon-theme/install.sh blue"
sh -c "~/GIT-REPOS/CORE/Tela-icon-theme/install.sh black"
sh -c "~/GIT-REPOS/CORE/Tela-icon-theme/install.sh purple"

# Reversal
git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git ~/GIT-REPOS/CORE/Reversal-icon-theme
sh -c "~/GIT-REPOS/CORE/Reversal-icon-theme/install.sh -a"

# Flatery Icon Theme
git clone https://github.com/cbrnix/Flatery.git ~/GIT-REPOS/CORE/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery ~/.local/share/icons/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery-Indigo-Dark ~/.local/share/icons/Flatery-Indigo-Dark

# Catppuccin
# wget `curl --silent "https://api.github.com/repos/catppuccin/gtk/releases/latest" |grep browser_download_url | grep Macchiato.zip |grep -Po '"browser_download_url": "\K.*?(?=")'` -O ~/.themes/Catppuccin-blue.zip
# unzip -d ~/.themes/ ~/.themes/Catppuccin-blue.zip 
# wget `curl --silent "https://api.github.com/repos/catppuccin/gtk/releases/latest" |grep browser_download_url | grep Catppuccin-purple.zip |grep -Po '"browser_download_url": "\K.*?(?=")'` -O ~/.themes/Catppuccin-purple.zip
# unzip -d ~/.themes/ ~/.themes/Catppuccin-purple.zip


