# Simply workspace
#https://github.com/andyrichardson/simply-workspaces
git clone https://github.com/andyrichardson/simply-workspaces.git ~/.local/share/gnome-shell/extensions/simply.workspaces@andyrichardson.dev
dconf write /org/gnome/shell/overrides/dynamic-workspaces false
dconf write /org/gnome/desktop/wm/preferences/num-workspaces 4
