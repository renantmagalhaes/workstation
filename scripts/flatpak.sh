#!/bin/bash

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flathub Packages

## Kdenlive
sudo flatpak install -y flathub org.kde.kdenlive

## OBS Studio
sudo flatpak install -y flathub com.obsproject.Studio

## Obsidian
sudo flatpak install -y flathub md.obsidian.Obsidian

## Telegram
# sudo flatpak install -y flathub org.telegram.desktop
# sudo flatpak override --filesystem=home:ro org.telegram.desktop

## Plex media player
sudo flatpak install -y flathub tv.plex.PlexDesktop

## CopyQ - Clipboard manager
sudo flatpak install flathub com.github.hluk.copyq

## Save desktop1
sudo flatpak install flathub io.github.vikdevelop.SaveDesktop

## StreamDeck - StreamController
sudo flatpak install flathub com.core447.StreamController

## Stremio
sudo flatpak install flathub com.stremio.Stremio

## Bottles - Game on Linux
# sudo flatpak install flathub com.usebottles.bottles

## Play on Linux - Game on Linux
# sudo flatpak install flathub com.playonlinux.PlayOnLinux4

## moonshine
# sudo flatpak install flathub com.moonlight_stream.Moonlight

## rustDesk
# sudo flatpak install flathub com.rustdesk.RustDesk

## Mousam (weather)
sudo flatpak install flathub io.github.amit9838.mousam
