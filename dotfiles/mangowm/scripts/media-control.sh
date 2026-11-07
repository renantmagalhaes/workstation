#!/usr/bin/env bash
# =============================================================================
# Unified Media Control Dispatcher
# Directs playback commands to QuickShell bar's Media service (single source of truth).
# Falls back to playerctl if QuickShell is not running.
# =============================================================================

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mango/quickshell-bar"
[[ ! -d "$CONFIG_DIR" ]] && CONFIG_DIR="$HOME/.dotfiles/mangowm/quickshell-bar"

ACTION="${1:-play-pause}"

case "$ACTION" in
    play-pause|toggle) METHOD="toggle" ;;
    play)              METHOD="play" ;;
    pause)             METHOD="pause" ;;
    stop)              METHOD="stop" ;;
    next)              METHOD="next" ;;
    previous|prev)     METHOD="previous" ;;
    *)                 METHOD="toggle" ;;
esac

# 1. Attempt to dispatch via QuickShell IPC (keeps bar UI and shortcuts unified)
if pgrep -f "quickshell.*quickshell-bar" >/dev/null 2>&1; then
    if quickshell ipc -p "$CONFIG_DIR" call media "$METHOD" >/dev/null 2>&1; then
        exit 0
    fi
fi

# 2. Fallback to playerctl if QuickShell is not running or IPC didn't answer
if command -v playerctl >/dev/null 2>&1; then
    if [[ "$METHOD" =~ ^(toggle|play|pause)$ ]]; then
        CURRENT_PLAYER=$(playerctl metadata --format '{{playerName}}' 2>/dev/null || true)
        if [[ "${CURRENT_PLAYER,,}" =~ kdeconnect ]]; then
            exit 0
        fi
    fi
    exec playerctl "$ACTION"
fi
