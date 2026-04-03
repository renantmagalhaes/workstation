#!/bin/bash
set -e

# Detect the VirtualBox command (some distros capitalize differently)
if command -v VBoxManage >/dev/null 2>&1; then
	VBOX_CMD="VBoxManage"
elif command -v vboxmanage >/dev/null 2>&1; then
	VBOX_CMD="vboxmanage"
else
	echo >&2 "VirtualBox (VBoxManage) is not installed. Please install it first."
	exit 1
fi

# Get the full VirtualBox version (e.g., 7.2.6)
VERSION=$($VBOX_CMD --version | cut -dr -f1)
# Get major and minor versions for naming logic (e.g., 7.2)
MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)

# VirtualBox 7.2+ dropped "VM" from the Extension Pack filename
# Use awk for version comparison to avoid dependency on 'bc'
IS_NEWER_THAN_7_2=$(echo "$MAJOR_MINOR" | awk '{print ($1 >= 7.2) ? "1" : "0"}')

if [ "$IS_NEWER_THAN_7_2" -eq 1 ]; then
	FILENAME="Oracle_VirtualBox_Extension_Pack-$VERSION.vbox-extpack"
else
	FILENAME="Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack"
fi

URL="https://download.virtualbox.org/virtualbox/$VERSION/$FILENAME"
DEST="/tmp/$FILENAME"

echo "Detected VirtualBox version: $VERSION"
echo "Downloading Extension Pack from: $URL"

# Download the Extension Pack
if ! wget -q "$URL" -O "$DEST"; then
	echo >&2 "Error: Could not download Extension Pack for version $VERSION."
	echo >&2 "Please check if it exists at: $URL"
	exit 1
fi

# Install the Extension Pack with automated license acceptance
echo "Installing Extension Pack..."
# We accept the PUEL license by echoing 'y' to the installer
if yes | sudo $VBOX_CMD extpack install --replace "$DEST"; then
	echo "Extension Pack $VERSION installed successfully."
else
	echo >&2 "Error: Extension Pack installation failed."
	exit 1
fi

# Cleanup
rm -f "$DEST"