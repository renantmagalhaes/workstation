#!/bin/bash

# Get available memory in MB
avai_mem_m=$(free -m | grep Mem | awk '{print $7}')
# Convert available memory to GB for comparison
avai_mem_gb=$(echo "scale=2; $avai_mem_m / 1024" | bc)

# Define ANSI color codes
blue='#[fg=#8b9dc3]'
orange='#[fg=#ff9f00]'
red='#[fg=#ED4D5E]'

# Determine the color based on avai_mem_gb value
if (( $(echo "$avai_mem_gb < 1" | bc -l) )); then
    color=$red
elif (( $(echo "$avai_mem_gb >= 1 && $avai_mem_gb < 3" | bc -l) )); then
    color=$orange
else
    color=$blue
fi

# Print the available memory with the determined color
echo "${color} ${avai_mem_gb}G"
