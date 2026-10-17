#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Vivaldi Manual Snapshot Manager
# - Install / update latest snapshot standalone
# - Add launcher to ~/.local/bin/vivaldi-manual-snapshot (PATH)
# - Install icons and .desktop entry for system application search
# - Uninstall / remove / purge options with interactive menu and CLI flags
# ==============================================================================

TARGET_DIR="${HOME}/.local/opt/vivaldi-manual-snapshot"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
ICON_BASE_DIR="${HOME}/.local/share/icons/hicolor"
LAUNCHER="${BIN_DIR}/vivaldi-manual-snapshot"
DESKTOP_ENTRY="${DESKTOP_DIR}/vivaldi-manual-snapshot.desktop"
VERSION_FILE="${TARGET_DIR}/.version"
PROFILE_DIR="${HOME}/.config/vivaldi-manual-snapshot"
TEST_PROFILE_DIR="${HOME}/.config/vivaldi-snapshot-test"

# Colors for terminal output
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

# 1. Architecture detection
detect_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64)
      TAR_ARCH="x64"
      DEB_ARCH="amd64"
      ;;
    aarch64|arm64)
      TAR_ARCH="arm64"
      DEB_ARCH="arm64"
      ;;
    *)
      echo -e "${RED}[-] Unsupported architecture: ${arch}${RESET}" >&2
      exit 1
      ;;
  esac
}

# 2. Check installed version
get_installed_version() {
  if [ -f "${VERSION_FILE}" ]; then
    cat "${VERSION_FILE}"
  elif [ -x "${TARGET_DIR}/vivaldi-snapshot" ]; then
    "${TARGET_DIR}/vivaldi-snapshot" --version 2>/dev/null | awk '{print $2}' || echo "unknown"
  else
    echo "none"
  fi
}

# 3. Query latest snapshot version from repository / RSS
get_latest_version() {
  detect_arch
  local version=""

  # Query official Debian repo metadata (fastest & standard Vivaldi updater source)
  version="$(curl -fsL "https://repo.vivaldi.com/archive/deb/dists/stable/main/binary-${DEB_ARCH}/Packages.gz" 2>/dev/null \
    | gzip -d 2>/dev/null \
    | grep -A6 -x "Package: vivaldi-snapshot" \
    | sed -n 's/^Version: \([0-9.]*\).*/\1/p' \
    | sort -V \
    | tail -n 1 || true)"

  # Fallback to RSS feed if Packages.gz fails
  if [ -z "${version}" ]; then
    version="$(curl -sL "https://vivaldi.com/blog/snapshots/feed/" 2>/dev/null \
      | grep -oP "https://downloads\.vivaldi\.com/snapshot/vivaldi-snapshot-[0-9.]+-${TAR_ARCH}\.tar" \
      | head -n 1 \
      | grep -oP '(?<=vivaldi-snapshot-)[0-9.]+(?=-)' || true)"
  fi

  if [ -z "${version}" ]; then
    echo "unknown"
  else
    echo "${version}"
  fi
}

# 4. Status information
show_status() {
  local installed latest
  installed="$(get_installed_version)"
  echo -e "${CYAN}[+] Querying latest snapshot version...${RESET}"
  latest="$(get_latest_version)"

  echo ""
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "${BOLD}            Vivaldi Manual Snapshot Status               ${RESET}"
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "  Installed Version : ${BOLD}${installed}${RESET}"
  echo -e "  Latest Available  : ${BOLD}${latest}${RESET}"
  if [ "${installed}" = "none" ]; then
    echo -e "  Status            : ${YELLOW}Not installed${RESET}"
  elif [ "${installed}" = "${latest}" ]; then
    echo -e "  Status            : ${GREEN}Up to date ✓${RESET}"
  else
    echo -e "  Status            : ${YELLOW}Update available (${installed} -> ${latest})${RESET}"
  fi
  echo -e "  Install Path      : ${TARGET_DIR}"
  echo -e "  Launcher Path     : ${LAUNCHER}"
  echo -e "  Desktop Entry     : ${DESKTOP_ENTRY}"
  echo -e "  Profile Path      : ${PROFILE_DIR}"
  echo -e "${BOLD}==========================================================${RESET}"
  echo ""
}

# 5. Install / Update Snapshot
install_snapshot() {
  local force="${1:-0}"
  local req_version="${2:-latest}"
  detect_arch

  local version="${req_version}"
  if [ "${version}" = "latest" ]; then
    echo -e "${CYAN}[+] Checking for latest Vivaldi Snapshot...${RESET}"
    version="$(get_latest_version)"
    if [ "${version}" = "unknown" ] || [ -z "${version}" ]; then
      echo -e "${RED}[-] Could not determine latest version from online sources.${RESET}" >&2
      exit 1
    fi
  fi

  local installed
  installed="$(get_installed_version)"

  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "${BOLD}  Installing / Updating Vivaldi Manual Snapshot           ${RESET}"
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "  Target Version : ${GREEN}${version}${RESET}"
  echo -e "  Architecture   : ${ARCH} (${TAR_ARCH})"
  echo -e "  Target Dir     : ${TARGET_DIR}"
  echo ""

  mkdir -p "${TARGET_DIR}" "${BIN_DIR}" "${DESKTOP_DIR}"

  local needs_download=1
  if [ "${installed}" = "${version}" ] && [ "${force}" -eq 0 ] && [ -x "${TARGET_DIR}/vivaldi-snapshot" ]; then
    echo -e "${GREEN}[✓] Vivaldi Snapshot ${version} is already installed and up to date.${RESET}"
    needs_download=0
  fi

  if [ "${needs_download}" -eq 1 ]; then
    # Migrate if previous legacy directory exists with same version
    local legacy_dir="${HOME}/.local/opt/vivaldi-snapshot-${version%.*.*}"
    if [ -d "${legacy_dir}/snapshot-extracted" ] && [ "${force}" -eq 0 ] && [ ! -d "${TARGET_DIR}/snapshot-extracted" ]; then
      echo -e "${CYAN}[+] Migrating existing files from ${legacy_dir}...${RESET}"
      cp -a "${legacy_dir}/." "${TARGET_DIR}/"
    else
      local tar_name="vivaldi-snapshot-${version}-${TAR_ARCH}.tar"
      local tar_url="https://downloads.vivaldi.com/snapshot/${tar_name}"
      local tmp_dir
      tmp_dir="$(mktemp -d)"
      trap 'rm -rf "${tmp_dir}"' EXIT

      echo -e "${CYAN}[+] Downloading ${tar_name}...${RESET}"
      curl -fL --progress-bar "${tar_url}" -o "${tmp_dir}/${tar_name}"

      echo -e "${CYAN}[+] Extracting archive into ${TARGET_DIR}...${RESET}"
      rm -rf "${TARGET_DIR:?}"/*
      tar -xf "${tmp_dir}/${tar_name}" -C "${TARGET_DIR}" --strip-components=1
    fi

    chmod +x "${TARGET_DIR}/vivaldi-snapshot" 2>/dev/null || true
    chmod +x "${TARGET_DIR}/testrun" 2>/dev/null || true
    chmod +x "${TARGET_DIR}/install" 2>/dev/null || true

    # Initialize binary environment & codecs
    echo -e "${CYAN}[+] Initializing browser binary...${RESET}"
    "${TARGET_DIR}/vivaldi-snapshot" --version >/dev/null 2>&1 || true

    echo "${version}" > "${VERSION_FILE}"
  fi

  # Install high-res application icons
  echo -e "${CYAN}[+] Installing application icons...${RESET}"
  for size in 16x16 24x24 32x32 48x48 64x64 128x128 256x256; do
    mkdir -p "${ICON_BASE_DIR}/${size}/apps"
    local src_icon="${TARGET_DIR}/snapshot-extracted/share/icons/hicolor/${size}/apps/vivaldi-snapshot.png"
    if [ -f "${src_icon}" ]; then
      cp -f "${src_icon}" "${ICON_BASE_DIR}/${size}/apps/vivaldi-manual-snapshot.png"
    fi
  done

  # Create executable runner in ~/.local/bin/vivaldi-manual-snapshot
  echo -e "${CYAN}[+] Configuring launcher: ${LAUNCHER}...${RESET}"
  cat > "${LAUNCHER}" <<'EOF'
#!/usr/bin/env bash
# Standalone Vivaldi Manual Snapshot Runner
set -euo pipefail

TARGET_DIR="${HOME}/.local/opt/vivaldi-manual-snapshot"
PROFILE_DIR="${HOME}/.config/vivaldi-manual-snapshot"

if [ ! -x "${TARGET_DIR}/vivaldi-snapshot" ]; then
  echo "[-] Vivaldi Snapshot binary not found at ${TARGET_DIR}/vivaldi-snapshot" >&2
  exit 1
fi

# Pre-load Smart Tab Manager if available, or custom extension if provided
EXTENSION_DIR="${EXTENSION_DIR:-${HOME}/git/smart-tab-manager}"
LOAD_EXT_FLAG=()
if [ -n "${EXTENSION_DIR}" ] && [ -f "${EXTENSION_DIR}/manifest.json" ]; then
  LOAD_EXT_FLAG+=("--load-extension=${EXTENSION_DIR}")
fi

exec "${TARGET_DIR}/vivaldi-snapshot" \
  --user-data-dir="${PROFILE_DIR}" \
  --class="Vivaldi-manual-snapshot" \
  "${LOAD_EXT_FLAG[@]}" \
  "$@"
EOF
  chmod +x "${LAUNCHER}"

  # Backward compatibility symlink
  ln -sf "${LAUNCHER}" "${BIN_DIR}/vivaldi-snapshot-test"

  # Create .desktop file for system application search
  echo -e "${CYAN}[+] Configuring desktop search item: ${DESKTOP_ENTRY}...${RESET}"
  cat > "${DESKTOP_ENTRY}" <<EOF
[Desktop Entry]
Version=1.0
Name=Vivaldi Manual Snapshot
GenericName=Web Browser
Comment=Access the Web (Manual Snapshot Build)
Exec=${LAUNCHER} %U
Terminal=false
Icon=vivaldi-manual-snapshot
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=Vivaldi-manual-snapshot
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=${LAUNCHER} --new-window

[Desktop Action new-private-window]
Name=New Private Window
Exec=${LAUNCHER} --incognito
EOF
  chmod +x "${DESKTOP_ENTRY}"

  # Refresh desktop database & icon caches
  echo -e "${CYAN}[+] Updating system desktop database and icon caches...${RESET}"
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -tq "${ICON_BASE_DIR}" 2>/dev/null || true
  fi
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q "${DESKTOP_DIR}" 2>/dev/null || true
  fi

  echo ""
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "${GREEN}  ✓ Installation Complete! (${version})${RESET}"
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "You can launch Vivaldi Manual Snapshot via:"
  echo -e "  1. System App Search : Search '${BOLD}Vivaldi Manual Snapshot${RESET}'"
  echo -e "  2. Terminal Command  : ${CYAN}vivaldi-manual-snapshot${RESET}"
  echo -e "  3. Binary Full Path  : ${LAUNCHER}"
  echo ""
  echo -e "Profile directory (isolated): ${PROFILE_DIR}"
  echo -e "${BOLD}==========================================================${RESET}"
}

# 6. Uninstall / Remove Snapshot
uninstall_snapshot() {
  local purge="${1:-0}"

  echo ""
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "${YELLOW}  Uninstalling Vivaldi Manual Snapshot...${RESET}"
  echo -e "${BOLD}==========================================================${RESET}"

  # Remove binaries and target directories
  if [ -d "${TARGET_DIR}" ]; then
    echo -e "${CYAN}[+] Removing binary directory: ${TARGET_DIR}${RESET}"
    rm -rf "${TARGET_DIR}"
  fi

  # Clean up legacy folders if present
  rm -rf "${HOME}/.local/opt/vivaldi-snapshot-8.3" "${HOME}/.local/opt/vivaldi-snapshot-"* 2>/dev/null || true

  # Remove launcher script and symlinks
  if [ -f "${LAUNCHER}" ] || [ -L "${LAUNCHER}" ]; then
    echo -e "${CYAN}[+] Removing launcher: ${LAUNCHER}${RESET}"
    rm -f "${LAUNCHER}"
  fi
  if [ -f "${BIN_DIR}/vivaldi-snapshot-test" ] || [ -L "${BIN_DIR}/vivaldi-snapshot-test" ]; then
    rm -f "${BIN_DIR}/vivaldi-snapshot-test"
  fi

  # Remove desktop entry
  if [ -f "${DESKTOP_ENTRY}" ]; then
    echo -e "${CYAN}[+] Removing desktop entry: ${DESKTOP_ENTRY}${RESET}"
    rm -f "${DESKTOP_ENTRY}"
  fi

  # Remove installed icons
  echo -e "${CYAN}[+] Removing icons from ${ICON_BASE_DIR}...${RESET}"
  rm -f "${ICON_BASE_DIR}"/*/apps/vivaldi-manual-snapshot.png 2>/dev/null || true

  # Refresh system desktop database and icon caches
  echo -e "${CYAN}[+] Refreshing desktop databases...${RESET}"
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -tq "${ICON_BASE_DIR}" 2>/dev/null || true
  fi
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q "${DESKTOP_DIR}" 2>/dev/null || true
  fi

  # Handle profile directories
  if [ "${purge}" -eq 1 ]; then
    echo -e "${YELLOW}[+] Purging profile data...${RESET}"
    rm -rf "${PROFILE_DIR}" "${TEST_PROFILE_DIR}"
    echo -e "${GREEN}[✓] Removed profile data (${PROFILE_DIR}).${RESET}"
  else
    if [ -d "${PROFILE_DIR}" ]; then
      echo -e "${CYAN}[i] User profile preserved at: ${PROFILE_DIR}${RESET}"
      echo -e "    (Use --purge or option 5 to delete it)"
    fi
  fi

  echo ""
  echo -e "${BOLD}==========================================================${RESET}"
  echo -e "${GREEN}  ✓ Vivaldi Manual Snapshot successfully uninstalled!${RESET}"
  echo -e "${BOLD}==========================================================${RESET}"
  echo ""
}

# 7. Launch browser
launch_browser() {
  if [ ! -x "${LAUNCHER}" ]; then
    echo -e "${RED}[-] Vivaldi Manual Snapshot is not installed.${RESET}" >&2
    echo -e "    Run with --install to install it first."
    exit 1
  fi
  echo -e "${GREEN}[+] Launching Vivaldi Manual Snapshot...${RESET}"
  nohup "${LAUNCHER}" "$@" >/dev/null 2>&1 &
}

# 8. Interactive Menu
show_menu() {
  detect_arch
  local installed latest
  installed="$(get_installed_version)"
  echo -e "${CYAN}[+] Checking latest available version...${RESET}"
  latest="$(get_latest_version)"

  while true; do
    echo ""
    echo -e "${BOLD}==========================================================${RESET}"
    echo -e "${BOLD}             Vivaldi Manual Snapshot Manager              ${RESET}"
    echo -e "${BOLD}==========================================================${RESET}"
    if [ "${installed}" = "none" ]; then
      echo -e "  Installed Version : ${RED}Not installed${RESET}"
    elif [ "${installed}" = "${latest}" ]; then
      echo -e "  Installed Version : ${GREEN}${installed} (Up to date ✓)${RESET}"
    else
      echo -e "  Installed Version : ${YELLOW}${installed} (Update available)${RESET}"
    fi
    echo -e "  Latest Available  : ${CYAN}${latest}${RESET}"
    echo -e "----------------------------------------------------------"
    echo -e "  ${BOLD}1)${RESET} Install / Update to latest snapshot"
    echo -e "  ${BOLD}2)${RESET} Force reinstall snapshot (${latest})"
    echo -e "  ${BOLD}3)${RESET} Launch Vivaldi Manual Snapshot"
    echo -e "  ${BOLD}4)${RESET} Uninstall (Keep profile data)"
    echo -e "  ${BOLD}5)${RESET} Purge (Uninstall + Delete profile data)"
    echo -e "  ${BOLD}6)${RESET} View Status & Paths"
    echo -e "  ${BOLD}0)${RESET} Exit"
    echo -e "${BOLD}==========================================================${RESET}"
    read -rp "Please select an option [0-6]: " choice

    case "$choice" in
      1)
        install_snapshot 0 latest
        installed="$(get_installed_version)"
        ;;
      2)
        install_snapshot 1 latest
        installed="$(get_installed_version)"
        ;;
      3)
        launch_browser
        break
        ;;
      4)
        read -rp "Are you sure you want to uninstall Vivaldi Manual Snapshot? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          uninstall_snapshot 0
          installed="$(get_installed_version)"
        else
          echo "Uninstall cancelled."
        fi
        ;;
      5)
        read -rp "Are you sure you want to PURGE Vivaldi Manual Snapshot and its profile? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          uninstall_snapshot 1
          installed="$(get_installed_version)"
        else
          echo "Purge cancelled."
        fi
        ;;
      6)
        show_status
        ;;
      0|q|Q|exit)
        echo "Goodbye!"
        exit 0
        ;;
      *)
        echo -e "${RED}[-] Invalid option: ${choice}${RESET}"
        ;;
    esac
  done
}

# 9. Help message
show_help() {
  echo ""
  echo -e "${BOLD}Vivaldi Manual Snapshot Manager${RESET}"
  echo "Usage: $(basename "$0") [OPTION]"
  echo ""
  echo "Options:"
  echo "  -i, --install [VER]    Install or update snapshot (default: latest)"
  echo "  -f, --force            Force re-download and reinstall latest"
  echo "  -u, --uninstall        Uninstall snapshot, launcher, desktop entry & icons"
  echo "  -p, --purge            Uninstall and delete user profile data"
  echo "  -s, --status           Show installation status and versions"
  echo "  -l, --launch           Launch Vivaldi Manual Snapshot in background"
  echo "  -m, --menu             Open interactive menu (default when run in terminal without args)"
  echo "  -h, --help             Show this help message"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0")                # Opens interactive menu"
  echo "  $(basename "$0") --install      # Installs/updates latest snapshot directly"
  echo "  $(basename "$0") --uninstall    # Removes snapshot without removing profile"
  echo "  $(basename "$0") --purge        # Completely removes snapshot and profile"
  echo ""
}

# 10. CLI Argument Parsing
if [ $# -eq 0 ]; then
  if [ -t 0 ]; then
    show_menu
  else
    install_snapshot 0 latest
  fi
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--install)
      shift
      target_ver="${1:-latest}"
      if [[ "${target_ver}" =~ ^[0-9] ]] || [ "${target_ver}" = "latest" ]; then
        shift 2>/dev/null || true
      else
        target_ver="latest"
      fi
      install_snapshot 0 "${target_ver}"
      exit 0
      ;;
    -f|--force)
      shift
      target_ver="${1:-latest}"
      if [[ "${target_ver}" =~ ^[0-9] ]] || [ "${target_ver}" = "latest" ]; then
        shift 2>/dev/null || true
      else
        target_ver="latest"
      fi
      install_snapshot 1 "${target_ver}"
      exit 0
      ;;
    -u|--uninstall|--remove)
      uninstall_snapshot 0
      exit 0
      ;;
    -p|--purge)
      uninstall_snapshot 1
      exit 0
      ;;
    -s|--status)
      show_status
      exit 0
      ;;
    -l|--launch)
      shift
      launch_browser "$@"
      exit 0
      ;;
    -m|--menu)
      show_menu
      exit 0
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    [0-9]*)
      install_snapshot 0 "$1"
      exit 0
      ;;
    *)
      echo -e "${RED}[-] Unknown option: $1${RESET}" >&2
      show_help
      exit 1
      ;;
  esac
done
