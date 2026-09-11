#!/usr/bin/env bash
# Watchdog script to monitor and restart the island bar, the trigger waybar and
# mouse_actions.py for MangoWM.
# Checks every 10 seconds and relaunches if processes are not running

set -euo pipefail

# Function to check if a process with a specific command pattern is running
is_running() {
    local pattern="$1"
    pgrep -f "$pattern" >/dev/null 2>&1
}

# Function to launch the main bar (QuickShell island).
# To revert to Waybar, swap the body for the commented lines below and update
# the matching exec-once in startup.conf.
launch_main_bar() {
    if ! is_running "quickshell .*quickshell-bar"; then
        quickshell -n -p "$HOME/.dotfiles/mangowm/quickshell-bar" >/dev/null 2>&1 &
    fi
    # if ! is_running "waybar -c .*/waybar/config.jsonc"; then
    #     waybar -c "$HOME/.dotfiles/mangowm/waybar/config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/style.css" >/dev/null 2>&1 &
    # fi
}

# Function to launch the secondary/trigger waybar
launch_trigger_waybar() {
    if ! is_running "waybar -c .*/waybar/trigger_config.jsonc"; then
        waybar -c "$HOME/.dotfiles/mangowm/waybar/trigger_config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/trigger_style.css" >/dev/null 2>&1 &
    fi
}

# Function to launch mouse_actions.py
launch_mouse_actions() {
    if ! is_running "mangowm/scripts/mouse_actions.py"; then
        "$HOME/.dotfiles/mangowm/scripts/mouse_actions.py" --invert-hwheel >/dev/null 2>&1 &
    fi
}

# Main loop
while true; do
    launch_main_bar
    launch_trigger_waybar
    launch_mouse_actions
    sleep 10
done
