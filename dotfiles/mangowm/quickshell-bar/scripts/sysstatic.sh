#!/usr/bin/env bash
# Emit hardware/OS identity as JSON. Run once at startup, not on the poll
# timer -- none of it changes, and lspci is far too slow to call every few
# seconds.
set -uo pipefail

cpu=$(awk -F': ' '/^model name/{print $2; exit}' /proc/cpuinfo)
os=$(sed -n 's/^PRETTY_NAME="\?\([^"]*\)"\?$/\1/p' /etc/os-release 2>/dev/null | head -1)
kernel=$(uname -r)

# lspci -mm quotes each field; the device name is the 4th. Prefer the bracketed
# marketing name ("Navi 21 [Radeon RX 6800]") over the chip codename.
gpu=$(lspci -mm 2>/dev/null | awk -F'" "' '/VGA compatible controller|3D controller/{print $4; exit}')
bracketed=$(printf '%s' "$gpu" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')
[ -n "$bracketed" ] && gpu="$bracketed"

jq -cn \
  --arg cpu "${cpu:-}" \
  --arg os "${os:-}" \
  --arg kernel "${kernel:-}" \
  --arg gpu "${gpu:-}" \
  '{cpu:$cpu, os:$os, kernel:$kernel, gpu:$gpu}'
