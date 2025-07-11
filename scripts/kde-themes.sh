#!/bin/bash

# Themes
# Materia KDE
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/materia-kde/master/install.sh | sh

# # Orchis
# git clone https://github.com/vinceliuice/Orchis-kde.git ~/GIT-REPOS/CORE/Orchis-kde
# sh -c "~/GIT-REPOS/CORE/Orchis-kde/install.sh"
#
# # ChromeOS
# git clone https://github.com/vinceliuice/ChromeOS-kde.git ~/GIT-REPOS/CORE/ChromeOS-kde
# sh -c "~/GIT-REPOS/CORE/ChromeOS-kde/install.sh"
#
#
# # WhiteSur
# git clone https://github.com/vinceliuice/WhiteSur-kde.git ~/GIT-REPOS/CORE/WhiteSur-kde
# sh -c "~/GIT-REPOS/CORE/WhiteSur-kde/install.sh"

# # Layan Theme
# git clone https://github.com/vinceliuice/Layan-kde.git ~/GIT-REPOS/CORE/Layan-kde
# sh -c "~/GIT-REPOS/CORE/Layan-kde/install.sh"

# Graphite Theme
git clone https://github.com/vinceliuice/Graphite-kde-theme.git ~/GIT-REPOS/CORE/Graphite-kde-theme
sh -c "~/GIT-REPOS/CORE/Graphite-kde-theme/install.sh"

# Fluent
git clone https://github.com/vinceliuice/Fluent-kde.git ~/GIT-REPOS/CORE/Fluent-kde
sh -c "~/GIT-REPOS/CORE/Fluent-kde/install.sh --round"
sh -c "~/GIT-REPOS/CORE/Fluent-kde/install.sh --round --solid"

# KDE MacSequoia
git clone https://github.com/vinceliuice/MacSequoia-kde.git ~/GIT-REPOS/CORE/MacSequoia-kde
sh -c "~/GIT-REPOS/CORE/MacSequoia-kde/install.sh --round"
sh -c "~/GIT-REPOS/CORE/MacSequoia-kde/sddm/install.sh"

# Colloid icon theme
git clone https://github.com/vinceliuice/Colloid-icon-theme.git ~/GIT-REPOS/CORE/Colloid
sh -c "~/GIT-REPOS/CORE/Colloid/install.sh -notint"
sh -c "~/GIT-REPOS/CORE/Colloid/install.sh -s all -notint"

# SDDM
# ##
# wget https://github.com/renantmagalhaes/workstation/raw/static-files/sddm/sugar-candy.tar.gz -O /tmp/sugar-candy.tar.gz
# sudo tar -xzvf /tmp/sugar-candy.tar.gz -C /usr/share/sddm/themes
