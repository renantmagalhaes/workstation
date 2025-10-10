#!/usr/bin/env bash
# Install WineHQ Stable on Debian 12 (bookworm)
# - Validates OS/version
# - Adds i386 architecture (needed for many Windows apps)
# - Configures WineHQ key+repo under /etc/apt/keyrings
# - Installs winehq-stable with recommends
# Safe to re-run (idempotent).

set -euo pipefail

# --- Helpers ---
die() {
	echo "ERROR: $*" >&2
	exit 1
}
note() { echo "--> $*"; }

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
	die "This script must be run as root (use: sudo $0)"
fi

# --- OS validation ---
if [[ ! -r /etc/os-release ]]; then
	die "/etc/os-release not found. Cannot determine OS."
fi

# shellcheck disable=SC1091
source /etc/os-release

ID_LOWER="${ID,,}"
CODENAME="${VERSION_CODENAME:-}"
VERSION_ID_NUM="${VERSION_ID:-}"

if [[ "$ID_LOWER" != "debian" ]]; then
	die "This is '$ID' not Debian. Aborting to avoid breaking your system."
fi

if [[ "$CODENAME" != "bookworm" || "$VERSION_ID_NUM" != "12" ]]; then
	echo "Detected: Debian $VERSION_ID_NUM ($CODENAME)"
	die "This script only supports Debian 12 (bookworm). Aborting."
fi

note "Confirmed Debian 12 (bookworm). Proceeding."

# --- Pre-flight: required tools ---
for bin in wget gpg apt dpkg; do
	command -v "$bin" >/dev/null 2>&1 || die "Required command '$bin' not found."
done

# --- Enable i386 architecture (if not already) ---
if dpkg --print-foreign-architectures | grep -qx 'i386'; then
	note "i386 architecture already enabled."
else
	note "Enabling i386 architecture..."
	dpkg --add-architecture i386
fi

# --- Keyrings directory ---
KEYRING_DIR="/etc/apt/keyrings"
KEYFILE="$KEYRING_DIR/winehq-archive.key"
SRCFILE="/etc/apt/sources.list.d/winehq-bookworm.sources"
REPO_URL="https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources"
KEY_URL="https://dl.winehq.org/wine-builds/winehq.key"

note "Ensuring keyrings directory exists at $KEYRING_DIR..."
mkdir -pm755 "$KEYRING_DIR"

# --- Import WineHQ GPG key (dearmored) if missing or empty ---
if [[ -s "$KEYFILE" ]]; then
	note "WineHQ key already present at $KEYFILE."
else
	note "Fetching and installing WineHQ key..."
	wget -qO- "$KEY_URL" | gpg --dearmor -o "$KEYFILE"
	chmod 644 "$KEYFILE"
fi

# --- Add WineHQ repository (sources file) if missing ---
if [[ -s "$SRCFILE" ]]; then
	note "WineHQ sources already present at $SRCFILE."
else
	note "Adding WineHQ sources for bookworm..."
	wget -q -NP /etc/apt/sources.list.d/ "$REPO_URL"
fi

# --- Update package list ---
note "Updating apt package lists..."
apt update

# --- Install WineHQ stable with recommends ---
PKG="winehq-stable"
if dpkg -s "$PKG" >/dev/null 2>&1; then
	note "'$PKG' is already installed."
else
	note "Installing '$PKG' (this may take a while)..."
	apt install -y --install-recommends "$PKG"
fi

note "WineHQ installation complete. Verify with: wine --version"
