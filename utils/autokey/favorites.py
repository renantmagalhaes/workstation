import re
import subprocess
import time

def get_active_window_name():
    result = subprocess.run(["xdotool", "getactivewindow", "getwindowname"], capture_output=True, text=True)
    return result.stdout.strip()

# Check the active window's name
window_name = get_active_window_name()
print(window_name)

# Check if the window name contains "Microsoft Edge" at the end
if re.search(r"Edge$", window_name):
    # Simulate Ctrl+Shift+O using xdotool
    subprocess.run(["xdotool", "key", "ctrl+shift+o"])
else:
    print("Active window is not Microsoft Edge.")
