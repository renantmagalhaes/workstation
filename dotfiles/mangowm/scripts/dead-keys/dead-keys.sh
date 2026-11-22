#!/usr/bin/env bash

# Toggle Quickshell Dead Keys picker
CONFIG_DIR="$HOME/.dotfiles/mangowm/quickshell-bar"

if ! pgrep -f "quickshell.*quickshell-bar" > /dev/null 2>&1; then
    quickshell -n -p "$CONFIG_DIR" > /dev/null 2>&1 &
    sleep 0.4
fi

quickshell ipc -p "$CONFIG_DIR" call deadkeys toggle > /dev/null 2>&1
