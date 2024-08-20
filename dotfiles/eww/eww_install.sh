#!/bin/bash

ln -s -f $PWD/config ~/.config/eww
sudo zypper in rustup libdbusmenu-glib-devel libdbusmenu-glib4 libdbusmenu-gtk3-devel libdbusmenu-gtk3-4 libdbusmenu-gtk4 libdbusmenu-qt5-2 libdbusmenu-qt5-devel
git clone https://github.com/elkowar/eww ~/GIT-REPOS/CORE/eww
cd ~/GIT-REPOS/CORE/eww
cargo build --release --no-default-features --features x11
#cargo build --release --no-default-features --features=wayland
cd target/release
chmod +x ./eww
sudo ln -s -f $PWD/eww /usr/bin/eww



