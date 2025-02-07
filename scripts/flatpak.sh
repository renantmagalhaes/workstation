#!/bin/bash

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flathub Packages
## Slack
#sudo flatpak install -y flathub com.slack.Slack
#sudo flatpak override --filesystem=home:ro com.slack.Slack

## Skype
#sudo flatpak install -y flathub com.skype.Client

## Zoom
#sudo flatpak install -y flathub us.zoom.Zoom

## Microsoft Teams
#sudo flatpak install -y flathub com.microsoft.Teams
#sudo flatpak override --filesystem=home:ro com.microsoft.Teams

## Kdenlive
sudo flatpak install -y flathub org.kde.kdenlive

## OBS Studio
sudo flatpak install -y flathub com.obsproject.Studio

## Obsidian
sudo flatpak install -y flathub md.obsidian.Obsidian

# ## FFaudioConverter
# sudo flatpak install -y flathub com.github.Bleuzen.FFaudioConverter

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
sudo flatpak install flathub com.usebottles.bottles

## Play on Linux - Game on Linux
sudo flatpak install flathub com.playonlinux.PlayOnLinux4

## moonshine
sudo flatpak install flathub com.moonlight_stream.Moonlight

## rustDesk
sudo flatpak install flathub com.rustdesk.RustDesk
