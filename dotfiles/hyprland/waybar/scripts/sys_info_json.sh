#!/bin/bash
# Hardware Status Information for Waybar Custom JSON module
# Uses sensors to gather system info and returns JSON for Waybar to parse

# Process CPU Temperature
CPU_TEMP=$(sensors 2>/dev/null | awk '/^k10temp/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /Tctl/{sub(/\+/, "", $2); print $2; exit}')
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="N/A"
else
    # Remove decimal and unit string for display on the bar
    CPU_BAR=$(echo "$CPU_TEMP" | awk '{printf "%d", $1}')
fi

# Process GPU Temperature 
GPU_TEMP=$(sensors 2>/dev/null | awk '/^amdgpu/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /edge/{sub(/\+/, "", $2); print $2; exit}')
if [ -z "$GPU_TEMP" ]; then
    GPU_TEMP="N/A"
fi

# Process NVMe Temperature
NVME_TEMP=$(sensors 2>/dev/null | awk '/^nvme-/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /Composite/{sub(/\+/, "", $2); print $2; exit}')
if [ -z "$NVME_TEMP" ]; then
    NVME_TEMP="N/A"
fi

# Pango formatted tooltip text 
# We use \r for line breaks which Waybar parses properly
TOOLTIP="<span size='large' color='#89b4fa'><b>Hardware Status</b></span>\r\r"
TOOLTIP+="<span color='#fab387'>🌡️  <b>CPU Temp:</b></span>\t${CPU_TEMP}\r"
TOOLTIP+="<span color='#f38ba8'>🎮  <b>GPU Temp:</b></span>\t${GPU_TEMP}\r"
TOOLTIP+="<span color='#a6e3a1'>💾  <b>NVMe Temp:</b></span>\t${NVME_TEMP}"

# Format as JSON string
echo "{\"text\": \"${CPU_BAR}°C \", \"tooltip\": \"${TOOLTIP}\"}"
