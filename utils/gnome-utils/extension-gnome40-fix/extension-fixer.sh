#!/bin/bash

# Download deskrop scroller
rm -rf ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi
git clone https://github.com/BrOrlandi/Desktop-Scroller-GNOME-Extension.git ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi

#Fix Desktop Scroller
sed -i 's/3\.30/42/' ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi/metadata.json

# Fix SimplerOffMenu
sed -i 's/3\.36/40/' ~/.local/share/gnome-shell/extensions/SimplerOffMenu.kerkus@pm.me/metadata.json

# Multi Monitor
git clone https://github.com/realh/multi-monitors-add-on.git ~/GIT-REPOS/CORE/multi-monitors-add-on
cd ~/GIT-REPOS/CORE/multi-monitors-add-on
cp -r multi-monitors-add-on@spin83 ~/.local/share/gnome-shell/extensions/


