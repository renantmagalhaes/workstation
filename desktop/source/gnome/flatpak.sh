#!/bin/bash

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


# Flathub Packages for gnome only
## Slack
sudo flatpak install flathub org.gnome.Extensions