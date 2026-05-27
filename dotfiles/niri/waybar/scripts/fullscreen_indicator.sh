#!/usr/bin/env python3
import json
import subprocess
import sys

def check_fullscreen():
    try:
        windows = json.loads(subprocess.check_output(["niri", "msg", "-j", "windows"], text=True))
        workspaces = json.loads(subprocess.check_output(["niri", "msg", "-j", "workspaces"], text=True))
        outputs = json.loads(subprocess.check_output(["niri", "msg", "-j", "outputs"], text=True))
    except Exception:
        return False

    focused_window = None
    for w in windows:
        if w.get("is_focused"):
            focused_window = w
            break

    if not focused_window:
        return False

    workspace_id = focused_window.get("workspace_id")
    if workspace_id is None:
        return False

    workspace = None
    for ws in workspaces:
        if ws.get("id") == workspace_id:
            workspace = ws
            break

    if not workspace:
        return False

    output_name = workspace.get("output")
    if not output_name or output_name not in outputs:
        return False

    output = outputs[output_name]
    logical = output.get("logical", {})
    out_w = logical.get("width")
    
    if out_w is None:
        return False

    layout = focused_window.get("layout", {})
    tile_size = layout.get("tile_size")
    if not tile_size:
        return False

    tile_w = tile_size[0]
    
    if focused_window.get("is_floating"):
        win_size = layout.get("window_size")
        if win_size and abs(win_size[0] - out_w) < 10:
            return True
        return False

    if abs(tile_w - out_w) < 10:
        return True

    return False

def main():
    if check_fullscreen():
        print(" 󰊴 ")
    else:
        print("")

if __name__ == "__main__":
    main()
