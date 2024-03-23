#!/usr/bin/env python3

import subprocess
import re
import time


# Get the window ID of the currently active window
window_id = int(subprocess.getoutput("xdotool getactivewindow"))

# Get the position of the window using xwininfo
window_position = subprocess.getoutput(f"xwininfo -id {window_id} | grep 'Absolute upper-left X:'")

# Extract the window's X coordinate
window_x = int(window_position.split()[3])

# Get information about connected monitors and their positions
monitor_info = subprocess.getoutput("xrandr | grep ' connected'")

# Initialize variables to store monitor width and action
selected_monitor_width = ""
action = ""

# Iterate through each line of monitor information to find the one containing the window's position
for line in monitor_info.split('\n'):
    match = re.search(r'(\d+)x(\d+)\+(\d+)\+(\d+)', line)
    if match:
        monitor_width, monitor_height, monitor_x, monitor_y = map(int, match.groups())
        if monitor_x <= window_x < monitor_x + monitor_width:
            selected_monitor_width = monitor_width
            break

# Perform actions based on selected monitor width
if selected_monitor_width == 2560:
    subprocess.run(["xdotool", "key", "super+shift+Right"])
    
    action = "Shift+Super+Right"
elif selected_monitor_width == 1920:
    subprocess.run(["xdotool", "key", "super+shift+Left"])
    action = "Shift+Super+Left"

# Print monitor information and action
if selected_monitor_width:
    print(f"Current window is on Monitor: {monitor_width} x {monitor_height} at {monitor_x},{monitor_y}")
    print(f"Performing action: {action}")
else:
    print("Could not determine current monitor.")
