#!/bin/bash

# Install missing lib
# Create a temporary file name
TEMP_DEB="$(mktemp)" || {
    echo "Failed to create temp file"
    exit 1
}

# Download the file into the temporary file
curl -L "https://archive.debian.org/debian/pool/main/libj/libjpeg8/libjpeg8_8b-1_amd64.deb" -o "$TEMP_DEB" ||
    {
        echo "Download failed"
        rm -f "$TEMP_DEB"
        exit 1
    }

# Install the package using dpkg
sudo dpkg -i "$TEMP_DEB" ||
    {
        echo "Installation failed"
        rm -f "$TEMP_DEB"
        exit 1
    }

# Remove the temporary file after successful installation
rm -f "$TEMP_DEB"
echo "Installation successful!"

# Install parsec
# Create a temporary file name
TEMP_DEB="$(mktemp)" || {
    echo "Failed to create temp file"
    exit 1
}

# Download the file into the temporary file
curl -L "https://builds.parsec.app/package/parsec-linux.deb" -o "$TEMP_DEB" ||
    {
        echo "Download failed"
        rm -f "$TEMP_DEB"
        exit 1
    }

# Install the package using dpkg
sudo dpkg -i "$TEMP_DEB" ||
    {
        echo "Installation failed"
        rm -f "$TEMP_DEB"
        exit 1
    }

# Remove the temporary file after successful installation
rm -f "$TEMP_DEB"
echo "Installation successful!"
