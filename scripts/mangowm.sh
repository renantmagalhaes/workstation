#!/bin/bash
#
# MangoWM Installation Script for openSUSE & Debian
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

OS=""
if check_cmd zypper; then
    OS="opensuse"
    echo "✅ openSUSE detected"
elif check_cmd apt-get; then
    OS="debian"
    echo "✅ Debian/Ubuntu detected"
else
    echo "❌ This script only supports openSUSE and Debian"
    exit 1
fi

echo "📂 Setting up working directory at $CORE_DIR..."
mkdir -p "$CORE_DIR"

if [ "$OS" = "opensuse" ]; then
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
elif [ "$OS" = "debian" ]; then
    echo "🔄 Refreshing apt repositories..."
    sudo apt-get update

    echo "📦 Installing exact Debian dependencies..."
    sudo apt-get install -y \
        libwayland-dev \
        wayland-protocols \
        libinput-dev \
        libdrm-dev \
        libxkbcommon-dev \
        libpixman-1-dev \
        libdisplay-info-dev \
        libliftoff-dev \
        hwdata \
        libseat-dev \
        libpcre2-dev \
        xwayland \
        libxcb1-dev \
        libsystemd-dev \
        libgbm-dev \
        glslang-tools \
        libvulkan-dev \
        meson \
        ninja-build \
        git \
        build-essential \
        pkgconf \
        libgles-dev \
        libegl-dev \
        libxcb-composite0-dev \
        libxcb-render0-dev \
        libxcb-xfixes0-dev \
        libxcb-shape0-dev \
        libxcb-dri3-dev \
        libxcb-res0-dev \
        libxcb-render-util0-dev \
        libxcb-ewmh-dev \
        libxcb-icccm4-dev \
        libxcb-xinput-dev \
        libxcb-xkb-dev \
        libxcb-xrm-dev \
        libxcb-image0-dev \
        libxcb-errors-dev \
        libx11-xcb-dev
fi

if [ -d /usr/include/wlroots-0.19 ] && [ -f /usr/include/wlroots-0.19/wlr/render/egl.h ]; then
    echo "ℹ️ wlroots already built and installed with EGL, skipping."
else
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
fi

if [ -d /usr/include/scenefx-0.4 ]; then
    echo "ℹ️ scenefx already built and installed, skipping."
else
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
fi


if command -v mango >/dev/null 2>&1; then
    echo "ℹ️ MangoWM already built and installed, skipping."
else
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
fi


echo "📁 Linking MangoWM configuration folder..."
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSTATION_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
DOTFILES_DIR="$WORKSTATION_DIR/dotfiles"

mkdir -p "$HOME/.config"
if [ -d "$DOTFILES_DIR/mangowm" ]; then
    rm -rf "$HOME/.config/mango"
    ln -sfn "$DOTFILES_DIR/mangowm" "$HOME/.config/mango"
    echo "🔗 Linked $HOME/.config/mango → $DOTFILES_DIR/mangowm"
else
    echo "⚠️ Warning: $DOTFILES_DIR/mangowm not found, skipping symlink creation."
fi

echo ""
echo "🎉 MangoWM installation and build completed successfully!"
echo "#################################"
