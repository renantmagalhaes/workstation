#!/usr/bin/env python3
import subprocess
import json
import sys
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


def run_json(cmd, timeout=5):
    """Run command and return JSON output with timeout"""
    try:
        out = subprocess.check_output(cmd, text=True, timeout=timeout)
        return json.loads(out)
    except Exception as e:
        print(f"Error running command: {e}", file=sys.stderr)
        sys.exit(1)


def get_cursor_pos():
    """Get cursor position"""
    j = run_json(["hyprctl", "cursorpos", "-j"])
    return int(j["x"]), int(j["y"])


def get_window_at_position(x, y):
    """Get window class at cursor position"""
    clients = run_json(["hyprctl", "clients", "-j"])

    for client in clients:
        client_x = client["at"][0]
        client_y = client["at"][1]
        client_w = client["size"][0]
        client_h = client["size"][1]

        if (client_x <= x < client_x + client_w and
                client_y <= y < client_y + client_h):
            return client.get("class", ""), client.get("title", "(no title)")

    return None, None


def main():
    # Show notification
    subprocess.run([
        "dunstify", "-i", "window_list",
        "Find Window Class",
        "Click on the window you want to inspect..."
    ])

    # Find mouse device
    device_path, device_name = find_mouse_device()
    if not device_path:
        print("Error: Could not find mouse device", file=sys.stderr)
        subprocess.run([
            "dunstify", "-i", "window_list",
            "Find Window Class",
            "Error: Could not find mouse device"
        ])
        sys.exit(1)

    try:
        device = InputDevice(device_path)
        # Don't grab - read events without exclusive access to avoid freezing mouse

        # Wait for left mouse button click
        for event in device.read_loop():
            if event.type == EC.EV_KEY and event.code == EC.BTN_LEFT and event.value == 1:
                # Left button pressed
                # Small delay to ensure click is registered
                import time
                time.sleep(0.05)

                # Get cursor position
                cursor_x, cursor_y = get_cursor_pos()

                # Get window at that position
                window_class, window_title = get_window_at_position(
                    cursor_x, cursor_y)

                if not window_class:
                    subprocess.run([
                        "dunstify", "-i", "window_list",
                        "Find Window Class",
                        "No window found at cursor position"
                    ])
                    sys.exit(1)

                # Copy to clipboard
                subprocess.run(["wl-copy"], input=window_class, text=True)

                # Show success notification
                subprocess.run([
                    "dunstify", "-i", "window_list",
                    "Find Window Class",
                    f"Window class \"{window_class}\" copied to clipboard\nTitle: {window_title}"
                ])

                sys.exit(0)

    except PermissionError:
        print("Error: Permission denied. You may need to run with appropriate permissions.", file=sys.stderr)
        subprocess.run([
            "dunstify", "-i", "window_list",
            "Find Window Class",
            "Error: Permission denied"
        ])
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
