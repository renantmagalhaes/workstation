#!/bin/bash

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# hydrapaper for dual wallpapers
sudo flatpak install -y flathub org.gabmus.hydrapaper

# extensions manager
sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
