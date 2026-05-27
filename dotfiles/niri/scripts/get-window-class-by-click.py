#!/usr/bin/env python3
import subprocess
import sys
import time
from evdev import InputDevice, ecodes as EC, list_devices

def find_mouse_device():
    """Find the best mouse device automatically"""
    try:
        devices = list_devices()
        mouse_candidates = []

        for device_path in devices:
            try:
                device = InputDevice(device_path)
                device_name = device.name.lower()

                # Check if device has mouse capabilities
                has_rel = False
                try:
                    caps = device.capabilities
                    if isinstance(caps, dict) and EC.EV_REL in caps:
                        has_rel = True
                except (AttributeError, TypeError):
                    pass

                # Score devices based on name and capabilities
                score = 0
                if "mouse" in device_name:
                    score += 10
                if has_rel:
                    score += 1

                if score > 0:
                    mouse_candidates.append((score, device_path, device.name))

            except (OSError, PermissionError):
                continue
            except Exception:
                continue

        # Sort by score (highest first) and return the best match
        if mouse_candidates:
            mouse_candidates.sort(key=lambda x: x[0], reverse=True)
            best_score, best_path, best_name = mouse_candidates[0]
            return best_path, best_name

    except Exception:
        pass

    return None, None

def get_focused_window_info():
    """Get active monitor's focused window info from mmsg -g"""
    try:
        out = subprocess.check_output(["mmsg", "-g"], text=True)
        active_mon = None
        for line in out.splitlines():
            parts = line.strip().split()
            if len(parts) >= 3 and parts[1] == "selmon" and parts[2] == "1":
                active_mon = parts[0]
                break
        
        if not active_mon:
            return None, None

        appid = None
        title = None
        for line in out.splitlines():
            parts = line.strip().split(maxsplit=2)
            if len(parts) < 3 or parts[0] != active_mon:
                continue
            field, val = parts[1], parts[2]
            if field == "appid":
                appid = val
            elif field == "title":
                title = val
        return appid, title
    except Exception as e:
        print(f"Error getting window info: {e}", file=sys.stderr)
        return None, None

def main():
    # Show notification
    subprocess.run([
        "notify-send",
        "--app-name=Find Window Class",
        "--icon=window_list",
        "Find Window Class",
        "Click on the window you want to inspect..."
    ])

    # Find mouse device
    device_path, device_name = find_mouse_device()
    if not device_path:
        print("Error: Could not find mouse device", file=sys.stderr)
        subprocess.run([
            "notify-send",
            "--app-name=Find Window Class",
            "--icon=window_list",
            "Find Window Class",
            "Error: Could not find mouse device"
        ])
        sys.exit(1)

    try:
        device = InputDevice(device_path)

        # Wait for left mouse button click
        for event in device.read_loop():
            if event.type == EC.EV_KEY and event.code == EC.BTN_LEFT and event.value == 1:
                # Left button pressed
                # Small delay to ensure click/focus is registered by the WM
                time.sleep(0.15)

                # Get focused window info
                window_class, window_title = get_focused_window_info()

                if not window_class:
                    subprocess.run([
                        "notify-send",
                        "--app-name=Find Window Class",
                        "--icon=window_list",
                        "Find Window Class",
                        "No window found at cursor position"
                    ])
                    sys.exit(1)

                # Copy to clipboard
                subprocess.run(["wl-copy"], input=window_class, text=True)

                # Show success notification
                subprocess.run([
                    "notify-send",
                    "--app-name=Find Window Class",
                    "--icon=window_list",
                    "Find Window Class",
                    f"Window class \"{window_class}\" copied to clipboard\nTitle: {window_title}"
                ])

                sys.exit(0)

    except PermissionError:
        print("Error: Permission denied. You may need to run with appropriate permissions.", file=sys.stderr)
        subprocess.run([
            "notify-send",
            "--app-name=Find Window Class",
            "--icon=window_list",
            "Find Window Class",
            "Error: Permission denied (add user to input group or run setfacl)"
        ])
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
