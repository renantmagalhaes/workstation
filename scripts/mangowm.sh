#!/bin/bash
#
# MangoWM Installation Script for openSUSE & Debian
# Builds wlroots, scenefx, mangowm, waybar, and quickshell (Debian) from source,
# plus whichever of wayland/wayland-protocols/libdrm/xkbcommon/pixman the distro's
# own packages are too old to satisfy (each is version-gated, see below).
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
    libexpat-devel \
    libffi-devel \
    libxml2-devel \
    libpciaccess-devel \
    bison \
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
    build-essential \
    cmake \
    ninja-build \
    git \
    pkgconf \
    libcli11-dev \
    libjemalloc-dev \
    libdrm-dev \
    libgbm-dev \
    libwayland-dev \
    wayland-protocols \
    libinput-dev \
    libdisplay-info-dev \
    libliftoff-dev \
    hwdata \
    seatd \
    libseat-dev \
    libpcre2-dev \
    xwayland \
    libxcb1-dev \
    libxcb-composite0-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
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
    libx11-xcb-dev \
    libsystemd-dev \
    glslang-tools \
    libcjson-dev \
    libgles-dev \
    libegl-dev \
    libpipewire-0.3-dev \
    libpam0g-dev \
    libpolkit-gobject-1-dev \
    libpolkit-agent-1-dev \
    libglib2.0-dev \
    libglibmm-2.4-dev \
    libgtkmm-3.0-dev \
    libjsoncpp-dev \
    libsigc++-2.0-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libupower-glib-dev \
    libplayerctl-dev \
    libpulse-dev \
    libmpdclient-dev \
    libxkbregistry-dev \
    libgtk-layer-shell-dev \
    libwireplumber-0.5-dev \
    libdbusmenu-gtk3-dev \
    libexpat1-dev \
    libffi-dev \
    libxml2-dev \
    libpciaccess-dev \
    libdbus-1-dev \
    libunwind-dev \
    libdwarf-dev \
    libvulkan-dev \
    spirv-tools \
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-declarative-dev \
    qt6-declarative-private-dev \
    qt6-shadertools-dev \
    qt6-wayland \
    qt6-wayland-dev \
    qt6-svg-dev \
    bison \
    wlogout \
    qt6-wayland-private-dev \
    wlrctl \
    wlr-randr
fi

# Homebrew (linuxbrew) path cleanup and pkg-config sanitization
CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v linuxbrew | paste -sd: -)

echo "🧹 Checking for stray Homebrew-poisoned pkg-config files..."
for pc in /usr/lib*/pkgconfig/fmt.pc /usr/lib*/pkgconfig/spdlog.pc /usr/lib/*/pkgconfig/fmt.pc /usr/lib/*/pkgconfig/spdlog.pc; do
  if [ -f "$pc" ] && grep -q "linuxbrew" "$pc" 2>/dev/null; then
    echo "⚠️ Removing stray $pc (references linuxbrew, leftover from a previous build)"
    sudo rm -f "$pc"
  fi
done

# Helper function to clone/update and build Meson projects
build_meson_project() {
  local name="$1" repo_url="$2" ref="$3"
  shift 3
  local meson_opts=("$@")

  echo "📥 Cloning and building $name (ref: $ref)..."
  cd "$CORE_DIR"
  if [ -d "$name" ]; then
    echo "ℹ️ $name directory already exists, updating repo..."
    cd "$name"
    git fetch --all
    git checkout "$ref"
    if [ "$ref" = "master" ] || [ "$ref" = "main" ]; then
      git pull
    fi
  else
    git clone "$repo_url" "$name"
    cd "$name"
    git checkout "$ref"
  fi
  if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  PATH="$CLEAN_PATH" meson setup build -Dprefix=/usr "${meson_opts[@]}"
  PATH="$CLEAN_PATH" ninja -C build
  sudo ninja -C build install
}

# Helper function to clone/update and build CMake projects (e.g., QuickShell)
build_cmake_project() {
  local name="$1" repo_url="$2" ref="$3"

  echo "📥 Cloning and building $name via CMake (ref: $ref)..."
  cd "$CORE_DIR"
  if [ -d "$name" ]; then
    echo "ℹ️ $name directory already exists, updating repo..."
    cd "$name"
    git fetch --all
    git checkout "$ref"
    if [ "$ref" = "master" ] || [ "$ref" = "main" ]; then
      git pull
    fi
  else
    git clone "$repo_url" "$name"
    cd "$name"
    git checkout "$ref"
  fi
  if [ -d "build" ]; then
    echo "🧹 Cleaning previous build directory..."
    sudo rm -rf build
  fi
  PATH="$CLEAN_PATH" cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DVENDOR_CPPTRACE=ON
  PATH="$CLEAN_PATH" cmake --build build
  sudo cmake --install build
}

# Version-gated dependency builds
if pkg-config --atleast-version=1.24.0 wayland-server 2>/dev/null; then
  echo "ℹ️ wayland-server >= 1.24.0 already installed, skipping."
else
  build_meson_project wayland https://gitlab.freedesktop.org/wayland/wayland.git 1.26.0 \
    -Dtests=false -Ddocumentation=false
fi

if pkg-config --atleast-version=1.47 wayland-protocols 2>/dev/null; then
  echo "ℹ️ wayland-protocols >= 1.47 already installed, skipping."
else
  build_meson_project wayland-protocols https://gitlab.freedesktop.org/wayland/wayland-protocols.git 1.49
fi

if pkg-config --atleast-version=2.4.129 libdrm 2>/dev/null; then
  echo "ℹ️ libdrm >= 2.4.129 already installed, skipping."
else
  build_meson_project libdrm https://gitlab.freedesktop.org/mesa/libdrm.git libdrm-2.4.134 \
    -Dtests=false -Dcairo-tests=disabled -Dman-pages=disabled -Dvalgrind=disabled
fi

if pkg-config --atleast-version=1.8.0 xkbcommon 2>/dev/null; then
  echo "ℹ️ xkbcommon >= 1.8.0 already installed, skipping."
else
  build_meson_project libxkbcommon https://github.com/xkbcommon/libxkbcommon.git xkbcommon-1.13.2
fi

if pkg-config --atleast-version=0.46.0 pixman-1 2>/dev/null; then
  echo "ℹ️ pixman-1 >= 0.46.0 already installed, skipping."
else
  build_meson_project pixman https://gitlab.freedesktop.org/pixman/pixman.git pixman-0.46.4 \
    -Ddemos=disabled -Dtests=disabled
fi

if [ -d /usr/include/wlroots-0.20 ] && [ -f /usr/include/wlroots-0.20/wlr/render/egl.h ]; then
  echo "ℹ️ wlroots already built and installed with EGL, skipping."
else
  build_meson_project wlroots https://gitlab.freedesktop.org/wlroots/wlroots.git 0.20.2
fi

if [ -d /usr/include/scenefx-0.5 ]; then
  echo "ℹ️ scenefx already built and installed, skipping."
else
  build_meson_project scenefx https://github.com/wlrfx/scenefx.git 0.5
fi

build_meson_project mango https://github.com/mangowm/mango.git main

WAYBAR_REF="${WAYBAR_VERSION:-master}"
if command -v waybar >/dev/null 2>&1 && strings "$(command -v waybar)" 2>/dev/null | grep -qx "mango/workspaces"; then
  echo "ℹ️ Waybar with MangoWM IPC support already built and installed, skipping."
  echo "   (remove /usr/bin/waybar and re-run this script to rebuild at a different WAYBAR_VERSION)"
else
  build_meson_project waybar https://github.com/Alexays/Waybar.git "$WAYBAR_REF" -Dtests=disabled
fi

# Build QuickShell from source on Debian
if [ "$OS" = "debian" ]; then
  if command -v quickshell >/dev/null 2>&1; then
    echo "ℹ️ QuickShell is already installed, skipping build."
  else
    build_cmake_project quickshell https://git.outfoxxed.me/outfoxxed/quickshell.git master
  fi
fi

# Lock/Hold Waybar against package manager overwrites
echo "🔒 Preventing package manager from replacing the source-built waybar..."
if [ "$OS" = "opensuse" ]; then
  if ! zypper locks | grep -q waybar; then
    sudo zypper addlock waybar
    echo "✅ Locked waybar in zypper (use 'zypper removelock waybar' to unlock)"
  else
    echo "ℹ️ waybar already locked in zypper."
  fi
elif [ "$OS" = "debian" ]; then
  if ! apt-mark showhold | grep -qx waybar; then
    sudo apt-mark hold waybar
    echo "✅ Held waybar in apt (use 'apt-mark unhold waybar' to unhold)"
  else
    echo "ℹ️ waybar already held in apt."
  fi
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

echo "🖱️ Installing ProtoArc EM01 NL udev rule (mouse battery query access)..."
UDEV_RULE_SRC="$DOTFILES_DIR/mangowm/udev/99-protoarc-mouse.rules"
UDEV_RULE_DEST="/etc/udev/rules.d/99-protoarc-mouse.rules"
if [ -f "$UDEV_RULE_SRC" ]; then
  if cmp -s "$UDEV_RULE_SRC" "$UDEV_RULE_DEST" 2>/dev/null; then
    echo "ℹ️ udev rule already up to date, skipping."
  else
    sudo cp "$UDEV_RULE_SRC" "$UDEV_RULE_DEST"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "✅ udev rule installed"
  fi
fi

if [ -d "$HOME/.config/rofi/rofi" ]; then
  echo "⚠️ Found nested rofi folder, fixing..."
  mv "$HOME/.config/rofi/rofi/"* "$HOME/.config/rofi/"
  rmdir "$HOME/.config/rofi/rofi"
fi

echo "📥 Setting up QS-Launcher..."
QS_LAUNCHER_DIR="$HOME/.QS-Launcher"
if [ -d "$QS_LAUNCHER_DIR/.git" ]; then
  echo "ℹ️ QS-Launcher already cloned, skipping."
else
  rm -rf "$QS_LAUNCHER_DIR"
  git clone git@github.com:renantmagalhaes/QS-Launcher.git "$QS_LAUNCHER_DIR" || true
fi

echo "#############################################################"
echo "##🎉 MangoWM installation and build completed successfully!##"
echo "#############################################################"