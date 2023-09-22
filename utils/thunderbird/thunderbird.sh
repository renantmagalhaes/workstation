#!/bin/bash

# Function to exit in case of an error
handle_error() {
    echo "$1"
    exit 1
}

# Get the latest Thunderbird version number from the release notes
LATEST_VERSION=$(curl -s https://www.thunderbird.net/en-US/thunderbird/releases/ | grep -oE 'thunderbird-[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | cut -d'-' -f2)

# Check if the version number was found
[ -z "$LATEST_VERSION" ] && handle_error "Failed to find the latest version of Thunderbird."

# Construct the download URL
URL="https://download.mozilla.org/?product=thunderbird-$LATEST_VERSION-SSL&os=linux64&lang=en-GB"

# Download Thunderbird
echo "Downloading Thunderbird version $LATEST_VERSION..."
TMP_FILE=$(sudo mktemp)
sudo curl -L "$URL" -o "$TMP_FILE"

# Check if the download was successful
[ $? -ne 0 ] && handle_error "Failed to download Thunderbird."

# Extract Thunderbird
echo "Extracting Thunderbird..."
sudo tar xjf "$TMP_FILE" -C /opt/

# Create a symbolic link to make it available system-wide
sudo ln -sf /opt/thunderbird/thunderbird /usr/bin/thunderbird

# thunderbird.desktop
sudo wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/installing-thunderbird-linux/thunderbird.desktop -P /usr/local/share/applications

# Clean up
rm "$TMP_FILE"

echo "Thunderbird version $LATEST_VERSION installed successfully!"
