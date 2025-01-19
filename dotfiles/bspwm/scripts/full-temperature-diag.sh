#!/bin/bash

# Extract and format CPU temperature (Tctl)
cpu_temp=$(sensors | grep -m 1 'Tctl' | awk '{print $2}' | sed 's/+//g' | cut -d '.' -f 1)

# Extract and format GPU temperature (edge)
gpu_temp=$(sensors | grep -A 10 'amdgpu-pci' | grep -m 1 'edge' | awk '{print $2}' | sed 's/+//g' | cut -d '.' -f 1)

# Extract and format NVMe temperature (Composite)
nvme_temp=$(sensors | grep -A 10 'nvme-pci' | grep -m 1 'Composite' | awk '{print $2}' | sed 's/+//g' | cut -d '.' -f 1)

# Output the values in a single line
echo " ${cpu_temp:-N/A}°C  󰢮 ${gpu_temp:-N/A}°C  󰋊 ${nvme_temp:-N/A}°C"
