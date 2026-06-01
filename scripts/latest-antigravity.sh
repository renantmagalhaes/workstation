#!/bin/bash
# Install / Update Google Antigravity Desktop App, IDE, and CLI for Linux x64
#
# This script dynamically fetches the latest versions of the Antigravity Hub/Desktop,
# Antigravity IDE, and Antigravity CLI directly from the official website.
#
set -euo pipefail

echo "========================================="
echo " Installing Google Antigravity Suite"
echo "========================================="

# Create a temporary directory in the workspace (or use /tmp safely)
TEMP_DIR="/tmp/antigravity-install"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# 1. Fetch the latest release details from the website
echo "🔍 Fetching the latest release URLs..."
MAIN_JS=$(curl -s --compressed https://antigravity.google/download | grep -oE 'main-[A-Z0-9]+\.js' | head -n 1)

if [ -z "$MAIN_JS" ]; then
    echo "❌ Error: Could not find main JS bundle on the Antigravity download page." >&2
    exit 1
fi

HUB_URL=$(curl -s --compressed "https://antigravity.google/$MAIN_JS" | grep -oE 'https://storage.googleapis.com/antigravity-public/antigravity-hub/[0-9.]+-[0-9]+/linux-x64/Antigravity.tar.gz' | head -n 1)
IDE_URL=$(curl -s --compressed "https://antigravity.google/$MAIN_JS" | grep -oE 'https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/[0-9.]+-[0-9]+/linux-x64/Antigravity%20IDE.tar.gz' | head -n 1)

# 2. Download and install the Antigravity CLI (agy)
echo "📥 Installing/Updating Antigravity CLI (agy)..."
curl -fsSL https://antigravity.google/cli/install.sh | sudo bash -s -- --dir /usr/local/bin

# 3. Setup Icons
echo "🎨 Fetching Antigravity icon..."
sudo wget -q -O /usr/share/pixmaps/antigravity.png https://antigravity.google/assets/image/antigravity-logo.png

# 4. Download and Install Antigravity Desktop / Hub
if [ -n "$HUB_URL" ]; then
    echo "📥 Downloading Antigravity Desktop App from $HUB_URL..."
    wget "$HUB_URL" -O antigravity-desktop.tar.gz

    echo "⚙️ Installing Antigravity Desktop App..."
    sudo rm -rf /opt/antigravity
    sudo mkdir -p /opt/antigravity
    sudo tar -C /opt/antigravity -xzf antigravity-desktop.tar.gz --strip-components=1

    # Link executable
    sudo ln -sf /opt/antigravity/antigravity /usr/local/bin/antigravity

    # Create Desktop Shortcut
    echo "📝 Creating Desktop entry for Antigravity..."
    sudo tee /usr/share/applications/antigravity.desktop > /dev/null <<EOL
[Desktop Entry]
Name=Google Antigravity
Exec=/usr/local/bin/antigravity
Icon=antigravity
Type=Application
Terminal=false
Comment=Build the new way with AI agents
Categories=Development;
EOL
else
    echo "⚠️ Warning: Could not resolve Antigravity Desktop App download URL."
fi

# 5. Download and Install Antigravity IDE
if [ -n "$IDE_URL" ]; then
    echo "📥 Downloading Antigravity IDE from $IDE_URL..."
    wget "$IDE_URL" -O antigravity-ide.tar.gz

    echo "⚙️ Installing Antigravity IDE..."
    sudo rm -rf /opt/antigravity-ide
    sudo mkdir -p /opt/antigravity-ide
    sudo tar -C /opt/antigravity-ide -xzf antigravity-ide.tar.gz --strip-components=1

    # Link executable
    sudo ln -sf /opt/antigravity-ide/antigravity-ide /usr/local/bin/antigravity-ide

    # Create Desktop Shortcut
    echo "📝 Creating Desktop entry for Antigravity IDE..."
    sudo tee /usr/share/applications/antigravity-ide.desktop > /dev/null <<EOL
[Desktop Entry]
Name=Google Antigravity IDE
Exec=/usr/local/bin/antigravity-ide
Icon=antigravity
Type=Application
Terminal=false
Comment=Official IDE for Google Antigravity
Categories=Development;IDE;
EOL
else
    echo "⚠️ Warning: Could not resolve Antigravity IDE download URL."
fi

# Cleanup temp files
cd /
rm -rf "$TEMP_DIR"

echo "✨ Google Antigravity Suite installed successfully!"
echo "Commands available: 'agy', 'antigravity', 'antigravity-ide'"
