#!/usr/bin/env bash
# Fast path: Hyprland says "Invalid" when there is no active window
if hyprctl activewindow | grep -q '^Invalid'; then
  exec jgmenu --config-file=~/.dotfiles/hyprland/hypr/jgmenu/jgmenurc --at-pointer
fi
