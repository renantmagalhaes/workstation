#!/bin/bash
#
# Vicinae Launcher Setup Script for openSUSE & Debian
# Installs Vicinae, builds and installs the local extensions, and sets up
# ~/.dotfiles symlinks.
#

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSTATION_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
DOTFILES_DIR="$WORKSTATION_DIR/dotfiles"
PLUGINS_DIR="$DOTFILES_DIR/vicinae/plugins"

# Prevent running as root
if [ "$(id -u)" = "0" ]; then
  echo "❌ Do not run this script as root"
  exit 1
fi

echo "#################################"
echo "#      Vicinae Setup           #"
echo "#################################"
echo ""

check_cmd() {
  command -v "$1" 2>/dev/null
}

# Dotfiles symlink (same convention as mangowm.sh & system scripts)
echo "🔗 Setting up main dotfiles symlink..."
DOTFILES="$HOME/.dotfiles"
if [[ ! -L "$DOTFILES" ]] || [[ "$(readlink "$DOTFILES")" != "$DOTFILES_DIR" ]]; then
  ln -sfn "$DOTFILES_DIR" "$DOTFILES"
  echo "✅ Main dotfiles symlink created"
fi

# Install Vicinae launcher
if ! check_cmd vicinae; then
  echo "⬇️ Installing Vicinae launcher..."
  curl -fsSL https://vicinae.com/install | sudo bash
fi

# Build & install the mango-unified extension from this repo
if [ -d "$PLUGINS_DIR/mango-unified" ]; then
  echo "🔨 Building mango-unified extension..."
  (
    cd "$PLUGINS_DIR/mango-unified"
    npm install
    npm run build
  )
else
  echo "⚠️  mango-unified plugin directory not found at $PLUGINS_DIR/mango-unified"
fi

# Start the user service
systemctl --user enable --now vicinae.service || true

echo "✅ Vicinae setup complete."