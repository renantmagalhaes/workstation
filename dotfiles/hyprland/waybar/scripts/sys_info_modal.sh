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

CPU_AVG=$(awk '{print $1 " / " $2 " / " $3}' /proc/loadavg 2>/dev/null)
if [ -z "$CPU_AVG" ]; then
    CPU_AVG="N/A"
fi

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

STORAGE_INFO=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
if [ -z "$STORAGE_INFO" ]; then
    STORAGE_INFO="N/A"
fi

# Formatted Output
MSG="<b><span size='large'>System Information</span></b>\n\n"
MSG+="  <b>CPU Avg:</b>       ${CPU_AVG}\n"
MSG+="🧠  <b>Memory:</b>        ${MEM_INFO}\n"
MSG+="🗄️  <b>Storage:</b>       ${STORAGE_INFO}\n"
MSG+="\n"
MSG+="\n"
MSG+="🌡️  <b>CPU Temp:</b>      ${CPU_TEMP}\n"
MSG+="🎮  <b>GPU Temp:</b>      ${GPU_TEMP}\n"
MSG+="💾  <b>NVMe Temp:</b>     ${NVME_TEMP}\n"

zenity --info \
    --title="System Information" \
    --text="${MSG}" \
    --width=320 \
    --window-icon=computer
