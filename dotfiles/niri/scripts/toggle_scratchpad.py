#!/usr/bin/env python3
import json
import subprocess
import sys

def run_cmd(args):
    return subprocess.run(args, capture_output=True, text=True)

def main():
    # 1. Get list of windows to find the scratchpad window
    res = run_cmd(["niri", "msg", "-j", "windows"])
    if res.returncode != 0:
        print("Niri is not running", file=sys.stderr)
        sys.exit(1)
        
    try:
        windows = json.loads(res.stdout)
    except Exception as e:
        print(f"Error parsing windows: {e}", file=sys.stderr)
        sys.exit(1)
        
    scratch_window = None
    for win in windows:
        if win.get("app_id") == "kitty-scratch":
            scratch_window = win
            break
            
    if scratch_window is None:
        # Window does not exist, spawn it
        subprocess.Popen(["kitty", "--class", "kitty-scratch", "-T", "kitty-scratch"])
        sys.exit(0)
        
    # 2. Get list of workspaces to find the focused one
    res_ws = run_cmd(["niri", "msg", "-j", "workspaces"])
    try:
        workspaces = json.loads(res_ws.stdout)
    except Exception as e:
        print(f"Error parsing workspaces: {e}", file=sys.stderr)
        sys.exit(1)
        
    focused_workspace = None
    for ws in workspaces:
        if ws.get("is_focused"):
            focused_workspace = ws
            break
            
    if not focused_workspace:
        print("Could not find focused workspace", file=sys.stderr)
        sys.exit(1)
        
    # 3. Toggle behavior
    if scratch_window.get("is_focused"):
        # If scratchpad is focused, move it to the monitor-specific hidden workspace and don't follow focus
        output = focused_workspace.get("output", "DP-1")
        target_scratch_ws = f"__scratchpad_{output}"
        
        target_ws = focused_workspace.get("name")
        should_cleanup_name = False
        if not target_ws:
            target_ws = "__temp_scratch_target"
            run_cmd(["niri", "msg", "action", "set-workspace-name", target_ws])
            should_cleanup_name = True
            
        try:
            run_cmd(["niri", "msg", "action", "move-window-to-workspace", target_scratch_ws, "--window-id", str(scratch_window["id"]), "--focus", "false"])
            run_cmd(["niri", "msg", "action", "focus-workspace", target_ws])
        finally:
            if should_cleanup_name:
                run_cmd(["niri", "msg", "action", "unset-workspace-name", target_ws])
    else:
        # Move it to the currently focused workspace and focus it.
        target_ws = focused_workspace.get("name")
        should_cleanup_name = False
        if not target_ws:
            target_ws = "__temp_scratch_target"
            run_cmd(["niri", "msg", "action", "set-workspace-name", target_ws])
            should_cleanup_name = True
            
        try:
            run_cmd(["niri", "msg", "action", "move-window-to-workspace", target_ws, "--window-id", str(scratch_window["id"])])
            run_cmd(["niri", "msg", "action", "focus-window", "--id", str(scratch_window["id"])])
        finally:
            if should_cleanup_name:
                run_cmd(["niri", "msg", "action", "unset-workspace-name", target_ws])

if __name__ == "__main__":
    main()
