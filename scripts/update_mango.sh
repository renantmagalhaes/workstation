#!/bin/bash
#
# Script to update MangoWM (mango) installation
# Pulls latest changes from repository, builds and installs.
#

set -e

CORE_DIR="$HOME/GIT-REPOS/CORE"

# Prevent running as root
if [ "$(id -u)" = "0" ]; then
    echo "❌ Do not run this script as root"
    exit 1
fi

# Check if running MangoWM or in a Mango session, and prevent running from the desktop
if pgrep -x mango >/dev/null 2>&1 || \
   [ "${XDG_CURRENT_DESKTOP,,}" = "mangowm" ] || \
   [ "${XDG_CURRENT_DESKTOP,,}" = "mango" ] || \
   [ "${DESKTOP_SESSION,,}" = "mangowm" ] || \
   [ "${DESKTOP_SESSION,,}" = "mango" ]; then
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        echo "❌ MangoWM is currently running or you are inside a Mango session."
        echo "   Please run this script from a TTY (e.g., switch with Ctrl+Alt+F3) and not from the desktop."
        exit 1
    fi
fi


echo "📥 Updating and building mangowm..."
mkdir -p "$CORE_DIR"
cd "$CORE_DIR"

if [ -d "mango" ]; then
    echo "ℹ️ mango directory already exists, updating repo..."
    cd mango
    git pull
else
    git clone https://github.com/mangowm/mango.git
    cd mango
fi

# Clean up build directory using sudo to avoid permission errors from previous root-owned build files
if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
fi

meson setup build -Dprefix=/usr
ninja -C build
sudo ninja -C build install
echo "✅ mangowm successfully updated!"

# Prompt the user to restart the machine
echo ""
read -rp "⚠️ A system restart is required to apply the MangoWM updates and ensure system stability. Restart now? (y/N): " choice
if [[ "$choice" =~ ^[Yy](es)?$ ]]; then
    echo "🔄 Rebooting..."
    sudo reboot
else
    echo "ℹ️ Please remember to restart your machine manually as soon as possible to ensure stability."
fi

