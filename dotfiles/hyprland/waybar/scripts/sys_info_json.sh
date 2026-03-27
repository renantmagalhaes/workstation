#!/bin/bash
# Hardware Status Information for Waybar Custom JSON module
# Uses sensors to gather system info and returns JSON for Waybar to parse

# Process CPU Temperature
CPU_TEMP=$(sensors 2>/dev/null | awk '/^k10temp/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /Tctl/{sub(/\+/, "", $2); print $2; exit}')
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="N/A"
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

# Use the 1-minute load average for the main bar text.
LOAD_AVG=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null)
if [ -z "$LOAD_AVG" ]; then
    LOAD_AVG="N/A"
fi

LOAD_CLASS="normal"
if [ "$LOAD_AVG" != "N/A" ] && awk "BEGIN {exit !($LOAD_AVG > 6)}"; then
    LOAD_CLASS="critical"
fi

CPU_AVG=$(awk '{print $1 " / " $2 " / " $3}' /proc/loadavg 2>/dev/null)
if [ -z "$CPU_AVG" ]; then
    CPU_AVG="N/A"
fi

# Memory usage from /proc/meminfo to avoid locale-dependent parsing.
MEM_INFO=$(awk '
    /^MemTotal:/ {total=$2}
    /^MemAvailable:/ {available=$2}
    END {
        if (total > 0 && available >= 0) {
            used=total-available
            printf "%.1f/%.1f GiB (%.0f%%)", used/1048576, total/1048576, (used/total)*100
        }
    }
' /proc/meminfo 2>/dev/null)
if [ -z "$MEM_INFO" ]; then
    MEM_INFO="N/A"
fi

# Root filesystem usage.
STORAGE_INFO=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
if [ -z "$STORAGE_INFO" ]; then
    STORAGE_INFO="N/A"
fi

# Pango formatted tooltip text 
# We use \r for line breaks which Waybar parses properly
TOOLTIP="<span size='large' color='#89b4fa'><b>System Information</b></span>\r\r"
TOOLTIP+="<span color='#89dceb'>  <b>CPU Avg:</b></span>\t${CPU_AVG}\r"
TOOLTIP+="<span color='#94e2d5'>🧠  <b>Memory:</b></span>\t${MEM_INFO}\r"
TOOLTIP+="<span color='#f9e2af'>🗄️  <b>Storage:</b></span>\t${STORAGE_INFO}\r"
TOOLTIP+="\r"
TOOLTIP+="\r"
TOOLTIP+="<span color='#fab387'>🌡️  <b>CPU Temp:</b></span>\t${CPU_TEMP}\r"
TOOLTIP+="<span color='#f38ba8'>🎮  <b>GPU Temp:</b></span>\t${GPU_TEMP}\r"
TOOLTIP+="<span color='#a6e3a1'>💾  <b>NVMe Temp:</b></span>\t${NVME_TEMP}"

# Format as JSON string
echo "{\"text\": \"${LOAD_AVG} \", \"tooltip\": \"${TOOLTIP}\", \"class\": \"${LOAD_CLASS}\"}"
