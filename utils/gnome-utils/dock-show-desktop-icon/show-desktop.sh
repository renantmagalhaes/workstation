# install dependency
sudo apt-get install xdotool

# Create a shortcut icon for Show Desktop
cat <<EOF >> ~/.local/share/applications/show-desktop.desktop
[Desktop Entry]
Type=Application
Name=Show Desktop
Icon=desktop
Exec=xdotool key --clearmodifiers Super+d
EOF

# Add show desktop to dock panel

echo "Add show desktop to dock panel"

