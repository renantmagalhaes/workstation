import subprocess

# Get the window ID of the currently active window using xprop
xprop_output = subprocess.check_output(['xprop', '-root', '_NET_ACTIVE_WINDOW'])
window_id = int(xprop_output.decode('utf-8').split()[-1], 16)

# Search for windows with the specified ID using wmctrl
wmctrl_output = subprocess.check_output(['wmctrl', '-lx'])
window_id_hex = format(window_id, '#010x')

# Check if the window title contains the string "Edge"
for line in wmctrl_output.decode('utf-8').split('\n'):
    if window_id_hex in line and "Edge" in line:
        # Send the key sequence "ctrl+shift+o" using xdotool
        subprocess.run(['xdotool', 'key', 'ctrl+shift+o'])
        break
