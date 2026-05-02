#!/bin/bash
#
# MangoWM Installation Script for openSUSE
# Builds wlroots, scenefx, and mangowm from source.
#

set -e

CORE_DIR="$HOME/GIT-REPOS/CORE"

check_cmd() {
    command -v "$1" 2>/dev/null
}

echo "#################################"
echo "#     MangoWM Installation      #"
echo "#################################"
echo ""

# Prevent running as root
if [ "$(id -u)" = "0" ]; then
    echo "❌ Do not run this script as root"
    exit 1
fi

# Confirm OpenSUSE system
if ! check_cmd zypper; then
    echo "❌ This script only supports openSUSE"
    exit 1
fi

echo "✅ openSUSE detected"
echo "📂 Setting up working directory at $CORE_DIR..."
mkdir -p "$CORE_DIR"

echo "🔄 Refreshing zypper repositories..."
sudo zypper refresh

echo "📦 Installing exact openSUSE dependencies..."
sudo zypper install -y \
    wayland-devel \
    wayland-protocols-devel \
    libinput-devel \
    libdrm-devel \
    libxkbcommon-devel \
    libpixman-1-0-devel \
    libdisplay-info-devel \
    libliftoff-devel \
    hwdata \
    seatd-devel \
    pcre2-devel \
    xwayland-devel \
    libxcb-devel \
    systemd-devel \
    libgbm-devel \
    glslang-devel \
    vulkan-devel \
    meson \
    ninja \
    git \
    gcc \
    gcc-c++ \
    pkgconf-pkg-config

echo "📥 Cloning and building wlroots..."
cd "$CORE_DIR"
if [ -d "wlroots" ]; then
    echo "ℹ️ wlroots directory already exists, updating repo..."
    cd wlroots
    git fetch --all
    git checkout 0.19.3
else
    git clone -b 0.19.3 https://gitlab.freedesktop.org/wlroots/wlroots.git
    cd wlroots
fi
if [ -d "build" ]; then
    meson setup build -Dprefix=/usr --wipe || rm -rf build && meson build -Dprefix=/usr
else
    meson build -Dprefix=/usr
fi
sudo ninja -C build install

echo "📥 Cloning and building scenefx..."
cd "$CORE_DIR"
if [ -d "scenefx" ]; then
    echo "ℹ️ scenefx directory already exists, updating repo..."
    cd scenefx
    git fetch --all
    git checkout 0.4.1
else
    git clone -b 0.4.1 https://github.com/wlrfx/scenefx.git
    cd scenefx
fi
if [ -d "build" ]; then
    meson setup build -Dprefix=/usr --wipe || rm -rf build && meson build -Dprefix=/usr
else
    meson build -Dprefix=/usr
fi
sudo ninja -C build install

echo "📥 Cloning and building mangowm..."
cd "$CORE_DIR"
if [ -d "mango" ]; then
    echo "ℹ️ mango directory already exists, updating repo..."
    cd mango
    git pull
else
    git clone https://github.com/mangowm/mango.git
    cd mango
fi
if [ -d "build" ]; then
    meson setup build -Dprefix=/usr --wipe || rm -rf build && meson build -Dprefix=/usr
else
    meson build -Dprefix=/usr
fi
sudo ninja -C build install

echo ""
echo "🎉 MangoWM installation and build completed successfully!"
echo "#################################"
