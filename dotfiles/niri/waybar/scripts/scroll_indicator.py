#!/usr/bin/env python3
import json
import subprocess
import sys

def get_niri_scroll_state():
    try:
        # Get windows
        windows_raw = subprocess.check_output(["niri", "msg", "-j", "windows"], text=True)
        windows = json.loads(windows_raw)
        
        # Get workspaces to find the focused workspace
        workspaces_raw = subprocess.check_output(["niri", "msg", "-j", "workspaces"], text=True)
        workspaces = json.loads(workspaces_raw)
    except Exception:
        # If Niri is not running or IPC fails, output nothing
        return None, None

    # Find the active/focused workspace
    active_workspace_id = None
    for ws in workspaces:
        if ws.get("is_focused") or ws.get("is_active"):
            active_workspace_id = ws.get("id")
            break
            
    if active_workspace_id is None:
        return None, None

    # Filter tiled windows on the active workspace
    workspace_windows = []
    for w in windows:
        if w.get("workspace_id") == active_workspace_id and not w.get("is_floating") and w.get("layout", {}).get("pos_in_scrolling_layout") is not None:
            workspace_windows.append(w)

    if not workspace_windows:
        return False, False

    # Find the active tiled window on this workspace.
    active_window = None
    for w in workspace_windows:
        if w.get("is_focused"):
            active_window = w
            break

    # If no tiled window is currently focused (e.g. a floating window or nothing is focused),
    # find the tiled window with the latest focus_timestamp.
    if active_window is None:
        workspace_windows_with_ts = [w for w in workspace_windows if w.get("focus_timestamp") is not None]
        if workspace_windows_with_ts:
            active_window = max(workspace_windows_with_ts, key=lambda w: (w["focus_timestamp"].get("secs", 0), w["focus_timestamp"].get("nanos", 0)))
        else:
            active_window = workspace_windows[0]

    # Get the focused column index
    focused_col = active_window["layout"]["pos_in_scrolling_layout"][0]

    # Check if there are columns to the left or right of the focused column
    has_left = any(w["layout"]["pos_in_scrolling_layout"][0] < focused_col for w in workspace_windows)
    has_right = any(w["layout"]["pos_in_scrolling_layout"][0] > focused_col for w in workspace_windows)

    return has_left, has_right

def main():
    has_left, has_right = get_niri_scroll_state()
    if has_left is None:
        print("")
        return

    if has_left and has_right:
        print("󰁍 󰁔")
    elif has_left:
        print("󰁍")
    elif has_right:
        print("󰁔")
    else:
        print("")

if __name__ == "__main__":
    main()
