#!/bin/bash

# Download deskrop scroller
rm -rf ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi
git clone https://github.com/BrOrlandi/Desktop-Scroller-GNOME-Extension.git ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi

#Fix Desktop Scroller
sed -i 's/3\.30/41/' ~/.local/share/gnome-shell/extensions/desktop-scroller@brorlandi/metadata.json



#Fix SimplerOffMenu
sed -i 's/3\.36/40/' ~/.local/share/gnome-shell/extensions/SimplerOffMenu.kerkus@pm.me/metadata.json


