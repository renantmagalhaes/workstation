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

# Link the entire dotfile-managed vicinae config dir into ~/.config/vicinae.
# Both settings.json (written by vicinae via the GUI) and config.jsonc live in
# the dotfile folder, so ALL settings changes are tracked in git automatically.
VICINAE_CONFIG_DIR="$HOME/.config/vicinae"
VICINAE_DOTFILE_DIR="$DOTFILES_DIR/vicinae/config"
echo "🔗 Linking vicinae config directory..."
mkdir -p "$(dirname "$VICINAE_CONFIG_DIR")"

# Remove the target dir and any prior partial symlinks so the whole-tree link is clean.
rm -rf "$VICINAE_CONFIG_DIR"
ln -sfn "$VICINAE_DOTFILE_DIR" "$VICINAE_CONFIG_DIR"
echo "✅ $VICINAE_CONFIG_DIR -> $VICINAE_DOTFILE_DIR"

# Build & install the unified-launcher extension from this repo
if [ -d "$PLUGINS_DIR/unified-launcher" ]; then
  echo "🔨 Building unified-launcher extension..."
  (
    cd "$PLUGINS_DIR/unified-launcher"
    npm install
    npm run build
  )
else
  echo "⚠️  unified-launcher plugin directory not found at $PLUGINS_DIR/unified-launcher"
fi

# Start the user service
systemctl --user enable --now vicinae.service || true

echo "✅ Vicinae setup complete."
