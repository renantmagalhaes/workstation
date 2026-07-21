#!/bin/bash
#
# MangoWM Installation Script for openSUSE & Debian
# Builds wlroots, scenefx, mangowm, and waybar from source, plus whichever
# of wayland/wayland-protocols/libdrm/xkbcommon/pixman the distro's own
# packages are too old to satisfy (each is version-gated, see below).
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
    libdbusmenu-gtk3-dev \
    libexpat1-dev \
    libffi-dev \
    libxml2-dev \
    libpciaccess-dev \
    bison
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

# Clones (or updates) a meson-based project into $CORE_DIR/<name> and
# builds+installs it. Re-run-safe: an existing checkout is fetched and
# switched to $ref rather than re-cloned; $ref="master" (or "main") also
# pulls to pick up new commits on repeat runs.
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

# --- wlroots 0.20's own dependency floor, and what Debian actually ships ---
# (checked against Debian trixie/testing; bookworm/stable is further behind
# on all of these). openSUSE Tumbleweed is rolling and usually already
# satisfies every one of these, so on it these are normally all no-ops:
#   dependency         wlroots needs   trixie ships
#   wayland-server      >=1.24.0        1.23.1   (too old)
#   wayland-protocols   >=1.47          1.44     (too old)
#   libdrm              >=2.4.129       2.4.124  (too old)
#   xkbcommon           >=1.8.0         1.7.0    (too old)
#   pixman-1            >=0.46.0        0.44.0   (too old, subdir requirement
#                                                  stricter than the top-level
#                                                  meson.build check)
# Each is version-gated so a fresh-enough system package is left alone.

if pkg-config --atleast-version=1.24.0 wayland-server 2>/dev/null; then
  echo "ℹ️ wayland-server >= 1.24.0 already installed, skipping."
else
  # -Dtests=false / -Ddocumentation=false: we only need the libraries and
  # wayland-scanner, not wayland's own test suite or its Doxygen/xmlto/dot
  # docs (which need a toolchain we don't otherwise install).
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
  # -Dcairo-tests / -Dman-pages / -Dvalgrind disabled: keeps this off the
  # critical path of needing cairo-dev/docutils/valgrind-dev installed for
  # functionality we don't use. Per-driver support (intel/amdgpu/radeon/...)
  # stays on its "auto" default and self-selects based on what's available.
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

# Unlike wlroots/scenefx (version-specific header path) or waybar (checked
# by feature string below), mango has no version pin and no reliable way
# to check "is the installed binary current" from the outside — it always
# tracks main. So, unlike those, we don't skip based on presence alone:
# `command -v mango` would stay true forever after the first install, even
# across wlroots/scenefx rebuilds that change mango's own ABI dependencies,
# permanently wedging it on a stale build. Always re-check out and rebuild;
# git pull is a fast no-op when there's nothing new, and this guarantees
# mango is linked against whatever wlroots/scenefx were just installed.
# (mango's default branch is "main", not "master" like wlroots/waybar.)
build_meson_project mango https://github.com/mangowm/mango.git main

# MangoWM 0.15 dropped the dwl-ipc Wayland protocol in favor of its own IPC
# socket. Waybar's replacement modules (mango/window, mango/workspaces)
# only exist on git master (see WAYBAR_VERSION at the top of this file),
# not in any tagged release yet, so it must be built from source.
WAYBAR_REF="${WAYBAR_VERSION:-master}"
if command -v waybar >/dev/null 2>&1 && strings "$(command -v waybar)" 2>/dev/null | grep -qx "mango/workspaces"; then
  echo "ℹ️ Waybar with MangoWM IPC support already built and installed, skipping."
  echo "   (remove /usr/bin/waybar and re-run this script to rebuild at a different WAYBAR_VERSION)"
else
  # -Dtests=disabled: this system's catch2 devel package is a version
  # mismatch with what Waybar's test suite expects (missing
  # catch2/internal/catch_config_prefix_messages.hpp), which fails the
  # build if the default "auto" pulls tests in. We don't need the tests,
  # only the waybar binary itself.
  build_meson_project waybar https://github.com/Alexays/Waybar.git "$WAYBAR_REF" -Dtests=disabled
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
