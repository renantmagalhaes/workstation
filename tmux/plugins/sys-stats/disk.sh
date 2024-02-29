#!/bin/bash

# Define ANSI color codes
grey='#[fg=#b2b2b2]'
red='#[fg=#ED4D5E]'

# Check if /mnt/c is mounted
if mount | grep -q '/mnt/c'; then
    # If /mnt/c is mounted, get the available space on /mnt/c
    avail_space=$(df -h --output=avail /mnt/c | awk 'NR==2{print $1}' | sed 's/G//')
else
    # If /mnt/c is not mounted, get the available space on /
    avail_space=$(df -h --output=avail / | awk 'NR==2{print $1}' | sed 's/G//')
fi

# Convert available space to a number for comparison
avail_space_num=$(echo $avail_space | sed 's/[A-Za-z]//g')

# Determine the color based on available space
if [[ $avail_space == *"T"* ]]; then
    color=$grey
elif (( $(echo "$avail_space_num >= 20" | bc -l) )); then
    color=$grey
else
    color=$red
fi

# Print the available space with the determined color
echo -e "${color} ${avail_space}G"
