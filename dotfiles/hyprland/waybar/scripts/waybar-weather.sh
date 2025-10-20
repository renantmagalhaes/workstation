#!/usr/bin/env bash
# Simple Waybar weather script using wttr.in
# Prints a short one-line weather string

set -euo pipefail

# You can change the location or format as desired
curl -fsS "https://wttr.in?format=1" 2>/dev/null || echo ""
