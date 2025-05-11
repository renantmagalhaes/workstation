#!/bin/bash

# Path style
FOLDER_LOCATION=$(pwd)

# Install klassy - Window decorations

## OpenSUSE Tumbleweed/Leap build dependencies
sudo zypper in -y git cmake kf6-extra-cmake-modules gettext
sudo zypper in -y "cmake(KF5Config)" "cmake(KF5CoreAddons)" "cmake(KF5FrameworkIntegration)" "cmake(KF5GuiAddons)" "cmake(KF5Kirigami2)" "cmake(KF5WindowSystem)" "cmake(KF5I18n)" "cmake(KF5KCMUtils)" "cmake(Qt5DBus)" "cmake(Qt5Quick)" "cmake(Qt5Widgets)" "cmake(Qt5X11Extras)" "cmake(KDecoration3)" "cmake(KF6ColorScheme)" "cmake(KF6Config)" "cmake(KF6CoreAddons)" "cmake(KF6FrameworkIntegration)" "cmake(KF6GuiAddons)" "cmake(KF6I18n)" "cmake(KF6KCMUtils)" "cmake(KF6KirigamiPlatform)" "cmake(KF6WindowSystem)" "cmake(Qt6Core)" "cmake(Qt6DBus)" "cmake(Qt6Quick)" "cmake(Qt6Svg)" "cmake(Qt6Widgets)" "cmake(Qt6Xml)"

## Then download, build and install
git clone https://github.com/paulmcauley/klassy ~/GIT-REPOS/CORE/klassy
cd ~/GIT-REPOS/CORE/klassy
git checkout plasma6.3
./install.sh
cd $FOLDER_LOCATION

# Install Krohnkite - Tiling window

## Clean up Global accel
qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.cleanUp

## Install Krohnkite
REPO="anametologin/krohnkite"
DOWNLOAD_DIR="$HOME/GIT-REPOS/CORE/"

# Fetch the latest release information using the GitHub API
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract the .kwinscript asset URL
ASSET_URL=$(echo "$RELEASE_INFO" | grep -Eo '"browser_download_url": "([^"]+\.kwinscript)"' | sed -E 's/"browser_download_url": "(.*)"/\1/')

if [ -z "$ASSET_URL" ]; then
    echo "No .kwinscript file found in the latest release."
    exit 1
fi

echo "Asset URL extracted: $ASSET_URL"

# Download the .kwinscript file
KROHNKITE=$(basename "$ASSET_URL")
echo "Downloading $KROHNKITE..."
curl -L "$ASSET_URL" -o "$DOWNLOAD_DIR/$KROHNKITE"

if [ $? -ne 0 ]; then
    echo "Download failed."
    exit 1
fi

echo "Downloaded to $DOWNLOAD_DIR/$KROHNKITE"

# Install the script using kpackagetool6
kpackagetool6 -t KWin/Script -i "$DOWNLOAD_DIR/$KROHNKITE"

# Return path
cd $FOLDER_LOCATION
