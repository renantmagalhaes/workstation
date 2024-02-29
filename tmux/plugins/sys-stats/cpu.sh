#!/bin/bash

# Get the system load averages
load_avg=$(uptime | awk -F',|:' '{print $(NF-2)}')


# Define color codes
green='#[fg=#dcedc1]'
orange='#[fg=#ff9f00]'
red='#[fg=#ED4D5E]'


# Determine the color based on load_avg value
if (( $(echo "$load_avg < 2" | bc -l) )); then
    color=$green
elif (( $(echo "$load_avg >= 2 && $load_avg < 4" | bc -l) )); then
    color=$orange
else
    color=$red
fi

# Print the load averages with the determined color
echo -e "${color}$load_avg"