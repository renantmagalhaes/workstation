#!/bin/bash
#
# MangoWM Installation Script for openSUSE & Debian
# Builds wlroots, scenefx, mangowm, and waybar from source.
#

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSTATION_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
DOTFILES_DIR="$WORKSTATION_DIR/dotfiles"
CORE_DIR="$HOME/GIT-REPOS/CORE"

# Waybar version to build, as a tag or commit hash from
# https://github.com/Alexays/Waybar/commits/master (e.g. "0.15.0" or
# "456f78ec"). Leave empty to track the latest master commit.
#
# Why master: MangoWM 0.15 dropped the dwl-ipc Wayland protocol in favor of
# its own IPC socket. Waybar's replacement modules (mango/window,
# mango/workspaces) only exist on git master as of 2026-07 — no tagged
# Waybar release ships them yet. Once a release does, pin WAYBAR_VERSION
# to it for reproducibility.
WAYBAR_VERSION=""

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
    cJSON-devel \
    meson \
    ninja \
    git \
    gcc \
    gcc-c++ \
    pkgconf-pkg-config \
    gtkmm3-devel \
    glibmm2_4-devel \
    jsoncpp-devel \
    libsigc++2-devel \
    libnl3-devel \
    libupower-glib-devel \
    pipewire-devel \
    playerctl-devel \
    libpulse-devel \
    libmpdclient-devel \
    libxkbregistry-devel \
    gtk-layer-shell-devel \
    wireplumber-devel \
    libdbusmenu-gtk3-devel \
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
    wlrctl \
    wlr-randr \
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
    libcjson-dev \
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
    wlrctl \
    wlr-randr \
    libx11-xcb-dev \
    libgtkmm-3.0-dev \
    libglibmm-2.4-dev \
    libjsoncpp-dev \
    libsigc++-2.0-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libupower-glib-dev \
    libpipewire-0.3-dev \
    libplayerctl-dev \
    libpulse-dev \
    libmpdclient-dev \
    libxkbregistry-dev \
    libgtk-layer-shell-dev \
    libwireplumber-0.5-dev \
    libdbusmenu-gtk3-dev
fi

# Homebrew (linuxbrew) is common on dev workstations and ships its own
# fmt/spdlog/etc. If its bin dir is on PATH, meson's CMake dependency
# search finds those ahead of the system libs, silently mixing headers
# from one and the linked .so from another. That produced this exact
# crash when building Waybar:
#   waybar: symbol lookup error: waybar: undefined symbol: _ZN3fmt...
# Every from-source build below runs with linuxbrew stripped from PATH.
CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v linuxbrew | paste -sd: -)

# If an earlier, PATH-polluted build attempt got `ninja install`-ed, it
# can leave behind pkg-config files that hardcode a path into linuxbrew
# (e.g. /usr/lib64/pkgconfig/spdlog.pc pointing at
# /home/linuxbrew/.linuxbrew/lib/libfmt.so). Those poison every later
# build even with a clean PATH, since pkg-config finds them directly.
echo "🧹 Checking for stray Homebrew-poisoned pkg-config files..."
for pc in /usr/lib*/pkgconfig/fmt.pc /usr/lib*/pkgconfig/spdlog.pc /usr/lib/*/pkgconfig/fmt.pc /usr/lib/*/pkgconfig/spdlog.pc; do
  if [ -f "$pc" ] && grep -q "linuxbrew" "$pc" 2>/dev/null; then
    echo "⚠️ Removing stray $pc (references linuxbrew, leftover from a previous build)"
    sudo rm -f "$pc"
  fi
done

if [ -d /usr/include/wlroots-0.20 ] && [ -f /usr/include/wlroots-0.20/wlr/render/egl.h ]; then
  echo "ℹ️ wlroots already built and installed with EGL, skipping."
else
  echo "📥 Cloning and building wlroots..."
  cd "$CORE_DIR"
  if [ -d "wlroots" ]; then
    echo "ℹ️ wlroots directory already exists, updating repo..."
    cd wlroots
    git fetch --all
    git checkout 0.20.2
  else
    git clone -b 0.20.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
    cd wlroots
  fi
  if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  PATH="$CLEAN_PATH" meson setup build -Dprefix=/usr
  PATH="$CLEAN_PATH" ninja -C build
  sudo ninja -C build install
fi

if [ -d /usr/include/scenefx-0.5 ]; then
  echo "ℹ️ scenefx already built and installed, skipping."
else
  echo "📥 Cloning and building scenefx..."
  cd "$CORE_DIR"
  if [ -d "scenefx" ]; then
    echo "ℹ️ scenefx directory already exists, updating repo..."
    cd scenefx
    git fetch --all
    git checkout 0.5
  else
    git clone -b 0.5 https://github.com/wlrfx/scenefx.git
    cd scenefx
  fi
  if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  PATH="$CLEAN_PATH" meson setup build -Dprefix=/usr
  PATH="$CLEAN_PATH" ninja -C build
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
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  PATH="$CLEAN_PATH" meson setup build -Dprefix=/usr
  PATH="$CLEAN_PATH" ninja -C build
  sudo ninja -C build install
fi

# MangoWM 0.15 dropped the dwl-ipc Wayland protocol in favor of its own IPC
# socket. Waybar's replacement modules (mango/window, mango/workspaces)
# only exist on git master (see WAYBAR_VERSION at the top of this file),
# not in any tagged release yet, so it must be built from source.
WAYBAR_REF="${WAYBAR_VERSION:-master}"
if command -v waybar >/dev/null 2>&1 && strings "$(command -v waybar)" 2>/dev/null | grep -qx "mango/workspaces"; then
  echo "ℹ️ Waybar with MangoWM IPC support already built and installed, skipping."
  echo "   (remove /usr/bin/waybar and re-run this script to rebuild at a different WAYBAR_VERSION)"
else
  echo "📥 Cloning and building waybar (ref: $WAYBAR_REF, for mango/window + mango/workspaces support)..."
  cd "$CORE_DIR"
  if [ -d "waybar" ]; then
    echo "ℹ️ waybar directory already exists, updating repo..."
    cd waybar
    git fetch --all
    git checkout "$WAYBAR_REF"
    if [ "$WAYBAR_REF" = "master" ]; then
      git pull
    fi
  else
    git clone https://github.com/Alexays/Waybar.git waybar
    cd waybar
    git checkout "$WAYBAR_REF"
  fi
  if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  # -Dtests=disabled: this system's catch2 devel package is a version
  # mismatch with what Waybar's test suite expects (missing
  # catch2/internal/catch_config_prefix_messages.hpp), which fails the
  # build if the default "auto" pulls tests in. We don't need the tests,
  # only the waybar binary itself.
  PATH="$CLEAN_PATH" meson setup build -Dprefix=/usr -Dtests=disabled
  PATH="$CLEAN_PATH" ninja -C build
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
link_config "$DOTFILES_DIR/mangowm/waybar" "$HOME/.config/waybar"
link_config "$DOTFILES_DIR/mako" "$HOME/.config/mako"
link_config "$DOTFILES_DIR/rofi" "$HOME/.config/rofi"
link_config "$DOTFILES_DIR/mangowm/jgmenu" "$HOME/.config/jgmenu"
link_config "$DOTFILES_DIR/mangowm/waybar/extra/wlogout" "$HOME/.config/wlogout"

echo "⚙️ Creating swappy configuration..."
mkdir -p "$HOME/.config/swappy"
cat <<'EOF' >"$HOME/.config/swappy/config"
[Default]
save_dir=$HOME/Pictures/Screenshots
save_filename_format=Screenshot_%Y%m%d_%H%M%S.png
early_exit=true
EOF

if [ -d "$DOTFILES_DIR/mangowm/waybar/scripts" ]; then
  chmod +x "$DOTFILES_DIR/mangowm/waybar/scripts/"*.sh
fi

if [ -d "$DOTFILES_DIR/mangowm/scripts" ]; then
  chmod +x "$DOTFILES_DIR/mangowm/scripts/"*.sh
fi

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

echo "#############################################################"
echo "##🎉 MangoWM installation and build completed successfully!##"
echo "#############################################################"
