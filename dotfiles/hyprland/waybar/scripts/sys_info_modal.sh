#!/bin/bash

# Hardware Status Information Modal
# Uses sensors to gather system info and displays it with Zenity

# Process CPU Temperature
CPU_TEMP=$(sensors 2>/dev/null | awk '/^k10temp/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /Tctl/{print $2; exit}')
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="N/A"
fi

# Process GPU Temperature 
GPU_TEMP=$(sensors 2>/dev/null | awk '/^amdgpu/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /edge/{print $2; exit}')
if [ -z "$GPU_TEMP" ]; then
    GPU_TEMP="N/A"
fi

# Process NVMe Temperature
NVME_TEMP=$(sensors 2>/dev/null | awk '/^nvme-/{flag=1; next} /^$/{if(flag) {flag=0; next}} flag && /Composite/{print $2; exit}')
if [ -z "$NVME_TEMP" ]; then
    NVME_TEMP="N/A"
fi

# Formatted Output
MSG="<b><span size='large'>Hardware Status</span></b>\n\n"
MSG+="🌡️  <b>CPU Temp:</b>      ${CPU_TEMP}\n"
MSG+="🎮  <b>GPU Temp:</b>      ${GPU_TEMP}\n"
MSG+="💾  <b>NVMe Temp:</b>     ${NVME_TEMP}\n"

zenity --info \
    --title="System Information" \
    --text="${MSG}" \
    --width=320 \
    --window-icon=computer
