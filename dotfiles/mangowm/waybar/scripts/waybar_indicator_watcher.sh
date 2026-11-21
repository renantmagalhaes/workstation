#!/bin/bash
# Delegate watching logic to waybar_indicator_watcher.py
python3 "$(dirname "$(readlink -f "$0")")/waybar_indicator_watcher.py"
