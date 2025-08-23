#!/usr/bin/env bash
set -euo pipefail

# Nix Uninstaller for Linux (systemd)
# - Restores pre-Nix shell configs if backup files exist
# - Stops and disables nix-daemon if present
# - Removes /nix and per-user Nix artifacts
# - Safe to re-run

#############################
# Helpers
#############################
log() { printf '[nix-uninstall] %s\n' "$*" ; }
exists() { command -v "$1" >/dev/null 2>&1 ; }
is_systemd() { pidof systemd >/dev/null 2>&1 ; }

ALL_USERS=false
if [[ "${1:-}" == "--all-users" ]]; then
  ALL_USERS=true
fi

require_sudo() {
  if [[ $EUID -ne 0 ]]; then
    log "This must run as root, re-running with sudo..."
    exec sudo -E bash "$0" "${@}"
  fi
}
require_sudo "$@"

#############################
# Step 1: stop and disable nix-daemon if present
#############################
if is_systemd; then
  if systemctl list-unit-files | grep -q '^nix-daemon\.service'; then
    log "Stopping nix-daemon.service and nix-daemon.socket if active"
    systemctl stop nix-daemon.service 2>/dev/null || true
    systemctl stop nix-daemon.socket 2>/dev/null || true

    log "Disabling nix-daemon units"
    systemctl disable nix-daemon.service 2>/dev/null || true
    systemctl disable nix-daemon.socket 2>/dev/null || true

    log "Removing any leftover unit files in /etc/systemd/system"
    rm -f /etc/systemd/system/nix-daemon.service /etc/systemd/system/nix-daemon.socket || true

    log "Reloading systemd daemon"
    systemctl daemon-reload || true
  else
    log "No nix-daemon units registered"
  fi
else
  log "Systemd not detected, skipping service cleanup"
fi

#############################
# Step 2: restore shell configs from pre-Nix backups
#############################
restore_backup() {
  local live="$1"
  local backup="$2"
  if [[ -f "$backup" ]]; then
    # Make an extra safety copy of current live file if it exists
    if [[ -f "$live" ]]; then
      cp -a "$live" "${live}.bak.$(date +%F-%H%M%S)"
      log "Backed up current $(basename "$live") to ${live}.bak.*"
    fi
    mv -f "$backup" "$live"
    log "Restored $(basename "$live") from $(basename "$backup")"
  else
    log "No backup found for $(basename "$live"), skipping"
  fi
}

restore_backup /etc/zshrc /etc/zshrc.backup-before-nix
restore_backup /etc/bash.bashrc /etc/bash.bashrc.backup-before-nix
# Some distros use /etc/bashrc
restore_backup /etc/bashrc /etc/bashrc.backup-before-nix || true

#############################
# Step 3: remove Nix system directories
#############################
log "Removing system Nix directories"
rm -rf /etc/nix /nix || true

#############################
# Step 4: remove root's Nix artifacts
#############################
purge_user_nix() {
  local homedir="$1"
  if [[ -d "$homedir" ]]; then
    rm -rf \
      "$homedir/.nix-profile" \
      "$homedir/.nix-defexpr" \
      "$homedir/.nix-channels" \
      "$homedir/.local/state/nix" \
      "$homedir/.cache/nix" || true
    log "Purged Nix files in $homedir"
  fi
}

purge_user_nix /root

#############################
# Step 5: remove current user's Nix artifacts (if invoked via sudo from a login shell)
#############################
# Try to detect the invoking user
INVOCATOR="${SUDO_USER:-}"
if [[ -n "$INVOCATOR" && "$INVOCATOR" != "root" ]]; then
  purge_user_nix "/home/$INVOCATOR" || true
fi

#############################
# Step 6: optionally purge all users under /home
#############################
if $ALL_USERS; then
  log "Purging Nix files for all users in /home"
  for d in /home/*; do
    [[ -d "$d" ]] || continue
    purge_user_nix "$d"
  done
fi

#############################
# Step 7: final checks
#############################
log "Final checks"
if [[ -e /nix ]]; then
  log "Warning, /nix still exists. Inspect permissions and remove manually if needed."
else
  log "/nix is gone"
fi

# PATH check
if exists nix-env || exists nix; then
  log "A nix binary is still on PATH. It may be from a leftover profile. Removing ~/.nix-profile/bin from PATH in your shell config is recommended."
fi

log "Uninstall complete"
