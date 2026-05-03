#!/bin/bash
#
# MangoWM Installation Script for openSUSE & Debian
# Builds wlroots, scenefx, and mangowm from source.
#

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSTATION_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
DOTFILES_DIR="$WORKSTATION_DIR/dotfiles"
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

echo "🔗 Setting up main dotfiles symlink..."
DOTFILES="$HOME/.dotfiles"
if [[ ! -L "$DOTFILES" ]] || [[ "$(readlink "$DOTFILES")" != "$DOTFILES_DIR" ]]; then
    ln -sfn "$DOTFILES_DIR" "$DOTFILES"
    echo "✅ Main dotfiles symlink created"
fi

echo "📂 Setting up working directory at $CORE_DIR..."
mkdir -p "$CORE_DIR"

if [ "$OS" = "opensuse" ]; then
    echo "📦 Adding QuickShell repository..."
    sudo zypper addrepo https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo || true
    echo "🔄 Refreshing zypper repositories..."
    sudo zypper refresh

    echo "📦 Installing exact openSUSE dependencies and apps..."
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
        seatd \
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
        pkgconf-pkg-config \
        waybar \
        wofi \
        rofi \
        playerctl \
        pavucontrol \
        hyprlock \
        blueman \
        nwg-displays \
        hypridle \
        libevdev-devel \
        evtest \
        swappy \
        grim \
        slurp \
        wl-clipboard \
        mako \
        pamixer \
        wireplumber \
        wlogout \
        feh \
        lxappearance \
        scrot \
        NetworkManager-applet \
        papirus-icon-theme \
        pasystray \
        jgmenu \
        mate-polkit \
        libnotify-devel \
        libnotify-tools \
        gnome-calendar \
        cliphist \
        nautilus \
        xcb-util-cursor-devel \
        hyprshot \
        hyprpicker \
        awww \
        dunst \
        kitty
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
        seatd \
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
        meson setup build -Dprefix=/usr --wipe || (sudo rm -rf build && meson setup build -Dprefix=/usr)
    else
        meson setup build -Dprefix=/usr
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
        meson setup build -Dprefix=/usr --wipe || (sudo rm -rf build && meson setup build -Dprefix=/usr)
    else
        meson setup build -Dprefix=/usr
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
        meson setup build -Dprefix=/usr --wipe || (sudo rm -rf build && meson setup build -Dprefix=/usr)
    else
        meson setup build -Dprefix=/usr
    fi
    sudo ninja -C build install
fi


link_config() {
    SRC="$1"
    DEST="$2"

    if [ ! -e "$SRC" ]; then
        echo "⚠️ Missing source: $SRC, skipping."
        return
    fi

    rm -rf "$DEST"
    ln -sfn "$SRC" "$DEST"
    echo "🔗 Linked $DEST → $SRC"
}

echo "📁 Linking configuration folders..."
mkdir -p "$HOME/.config"

link_config "$DOTFILES_DIR/mangowm" "$HOME/.config/mango"
link_config "$DOTFILES_DIR/hyprland/waybar" "$HOME/.config/waybar"
link_config "$DOTFILES_DIR/mako" "$HOME/.config/mako"
link_config "$DOTFILES_DIR/rofi" "$HOME/.config/rofi"
link_config "$DOTFILES_DIR/hyprland/hypr/jgmenu" "$HOME/.config/jgmenu"
link_config "$DOTFILES_DIR/hyprland/waybar/extra/wlogout" "$HOME/.config/wlogout"

if [ -d "$HOME/.config/rofi/rofi" ]; then
    echo "⚠️ Found nested rofi folder, fixing..."
    mv "$HOME/.config/rofi/rofi/"* "$HOME/.config/rofi/"
    rmdir "$HOME/.config/rofi/rofi"
fi

if [ "$OS" = "opensuse" ]; then
    echo "📥 Setting up QS-Launcher..."
    QS_LAUNCHER_DIR="$HOME/.QS-Launcher"
    if [ -d "$QS_LAUNCHER_DIR/.git" ]; then
        echo "ℹ️ QS-Launcher already cloned, skipping."
    else
        rm -rf "$QS_LAUNCHER_DIR"
        git clone git@github.com:renantmagalhaes/QS-Launcher.git "$QS_LAUNCHER_DIR" || true
    fi
fi

echo ""
echo "🎉 MangoWM installation and build completed successfully!"
echo "#################################"
