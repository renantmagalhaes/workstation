#!/bin/bash
# Wrapper script to ensure polkit works from Hyprland keybinds
# This ensures the environment is properly set for GUI authentication

# Get environment from the current user session
# Try to get Wayland display from the running session
if [ -z "$WAYLAND_DISPLAY" ]; then
    # Try to find the Wayland display from the session
    for socket in /tmp/wayland-* /run/user/*/wayland-*; do
        if [ -S "$socket" ] 2>/dev/null; then
            export WAYLAND_DISPLAY="$(basename "$socket")"
            break
        fi
    done
fi

# Ensure XDG environment is set
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Get the actual script path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/inzone_reset_usb.sh"

# Run pkexec with the script
pkexec bash "$SCRIPT"
