#!/usr/bin/env python3
import subprocess
import os
import sys
import signal
import re

# Files to write state to
STATE_LEFT = "/tmp/mangowm_scroll_left"
STATE_RIGHT = "/tmp/mangowm_scroll_right"

def get_monitors_geometry():
    geom = {}
    try:
        output = subprocess.check_output(["wlr-randr"], text=True)
        current_mon = None
        for line in output.splitlines():
            if line and not line.startswith(" "):
                parts = line.split()
                if parts:
                    current_mon = parts[0]
                    geom[current_mon] = {"x": 0, "width": 2560}
            elif current_mon:
                line_str = line.strip()
                if "(current)" in line_str:
                    match = re.search(r"(\d+)x\d+\s+px", line_str)
                    if match:
                        geom[current_mon]["width"] = int(match.group(1))
                elif line_str.startswith("Position:"):
                    pos_parts = line_str.split()[1].split(",")
                    geom[current_mon]["x"] = int(pos_parts[0])
    except Exception:
        pass
    if "DP-1" not in geom:
        geom["DP-1"] = {"x": 0, "width": 2560}
    if "HDMI-A-1" not in geom:
        geom["HDMI-A-1"] = {"x": 2560, "width": 2560}
    return geom

def write_state(left_val, right_val, nl_appid="", nl_title="", nr_appid="", nr_title=""):
    states = [
        (STATE_LEFT, left_val),
        (STATE_RIGHT, right_val),
        ("/tmp/mangowm_next_left_appid", nl_appid),
        ("/tmp/mangowm_next_left_title", nl_title),
        ("/tmp/mangowm_next_right_appid", nr_appid),
        ("/tmp/mangowm_next_right_title", nr_title),
    ]
    for path, val in states:
        try:
            with open(path, "w") as f:
                f.write(val)
        except Exception:
            pass

def signal_waybar():
    try:
        pids_str = subprocess.check_output(["pgrep", "-f", "waybar -c .*config.jsonc"], text=True)
        pids = [int(pid) for pid in pids_str.strip().split() if pid.isdigit()]
        signum = signal.SIGRTMIN + 8
        for pid in pids:
            os.kill(pid, signum)
    except Exception:
        pass

def get_open_windows():
    try:
        all_output = subprocess.check_output(["wlrctl", "toplevel", "list"], text=True)
        min_output = subprocess.check_output(["wlrctl", "toplevel", "list", "state:minimized"], text=True)
    except Exception:
        return [], set()
    
    def parse_list(output, as_set=False):
        windows = set() if as_set else []
        for line in output.splitlines():
            if ":" in line:
                parts = line.split(":", 1)
                appid = parts[0].strip()
                title = parts[1].strip()
                if as_set:
                    windows.add((appid, title))
                else:
                    windows.append((appid, title))
        return windows

    return parse_list(all_output, as_set=False), parse_list(min_output, as_set=True)

def main():
    # Initialize state files
    write_state("", "")

    # Monitor geometries
    monitors_geom = get_monitors_geometry()

    # State database
    # tag_windows[tag] = [ { "title": title, "appid": appid, "x": x, "w": w, "minimized": bool } ]
    tag_windows = {}

    # Current compositor state
    active_monitor = None
    active_tag = 1
    focused_title = ""
    focused_appid = ""
    focused_x = 0
    focused_w = 0
    layout = ""

    # Start mmsg -w
    try:
        proc = subprocess.Popen(["mmsg", "-w"], stdout=subprocess.PIPE, text=True, bufsize=1)
    except Exception as e:
        print(f"Failed to start mmsg -w: {e}", file=sys.stderr)
        sys.exit(1)

    # Monitor list (to know active monitor status)
    monitors_focus = {}  # mon_name -> is_focused

    def update_indicators():
        nonlocal active_monitor, active_tag, focused_title, focused_appid, focused_x, focused_w, layout
        if not active_monitor or layout != "S":
            write_state("", "")
            signal_waybar()
            return

        # Get open/minimized windows from system
        all_wins, min_wins = get_open_windows()

        # Update windows in our database for active monitor and tag
        key = (active_monitor, active_tag)
        if key not in tag_windows:
            tag_windows[key] = []

        # Remove closed windows
        tag_windows[key] = [
            w for w in tag_windows[key]
            if (w["appid"], w["title"]) in all_wins
        ]

        # Update minimized flags
        for w in tag_windows[key]:
            w["minimized"] = (w["appid"], w["title"]) in min_wins

        # If we have focused window details, update or add it
        if focused_title and focused_appid:
            # Ensure the window is removed from all other monitor/tag lists
            for other_key in list(tag_windows.keys()):
                if other_key != key:
                    tag_windows[other_key] = [
                        w for w in tag_windows[other_key]
                        if not (w["appid"] == focused_appid and w["title"] == focused_title)
                    ]

            # Find if this window is already in the tag's database
            existing = None
            for w in tag_windows[key]:
                if w["appid"] == focused_appid and w["title"] == focused_title:
                    existing = w
                    break

            if not existing:
                # B is a new window (not yet in the database).
                # Find B's coordinate before scroll based on wlrctl layout order.
                active_wins_in_layout = []
                for appid, title in all_wins:
                    if (appid == focused_appid and title == focused_title) or any(w["appid"] == appid and w["title"] == title for w in tag_windows[key]):
                        active_wins_in_layout.append((appid, title))

                try:
                    b_idx = active_wins_in_layout.index((focused_appid, focused_title))
                except ValueError:
                    b_idx = -1

                b_x = None
                if b_idx != -1:
                    # wlrctl order is right-to-left.
                    # Search left in the list (ref_win is to the right of B in layout)
                    for i in range(b_idx - 1, -1, -1):
                        ref_appid, ref_title = active_wins_in_layout[i]
                        ref_win = next((w for w in tag_windows[key] if w["appid"] == ref_appid and w["title"] == ref_title), None)
                        if ref_win:
                            b_x = ref_win["x"] - focused_w - 5
                            break
                    # Search right in the list (ref_win is to the left of B in layout)
                    if b_x is None:
                        for i in range(b_idx + 1, len(active_wins_in_layout)):
                            ref_appid, ref_title = active_wins_in_layout[i]
                            ref_win = next((w for w in tag_windows[key] if w["appid"] == ref_appid and w["title"] == ref_title), None)
                            if ref_win:
                                b_x = ref_win["x"] + ref_win["w"] + 5
                                break

                if b_x is None:
                    b_x = focused_x

                existing = {
                    "appid": focused_appid,
                    "title": focused_title,
                    "x": b_x,
                    "w": focused_w,
                    "minimized": False
                }
                tag_windows[key].append(existing)

            # Apply scroll delta to all windows in the database
            dx = focused_x - existing["x"]
            if dx != 0:
                for w in tag_windows[key]:
                    w["x"] += dx
            existing["x"] = focused_x
            existing["w"] = focused_w
            existing["minimized"] = False

        # Get columns: non-minimized windows sorted by x
        columns = [w for w in tag_windows[key] if not w["minimized"]]
        columns.sort(key=lambda w: w["x"])

        # Find focused window index in columns
        focused_idx = -1
        for i, w in enumerate(columns):
            if w["appid"] == focused_appid and w["title"] == focused_title:
                focused_idx = i
                break

        show_left = False
        show_right = False
        nl_appid = ""
        nl_title = ""
        nr_appid = ""
        nr_title = ""

        mon_geom = monitors_geom.get(active_monitor, {"x": 0, "width": 2560})

        if len(columns) >= 2 and focused_idx != -1:
            for i in range(focused_idx):
                col = columns[i]
                left_rel = col["x"] - mon_geom["x"]
                right_rel = left_rel + col["w"]
                if right_rel <= 100:
                    show_left = True
                    break
            
            if show_left:
                nl_appid = columns[focused_idx - 1]["appid"]
                nl_title = columns[focused_idx - 1]["title"]

            for i in range(focused_idx + 1, len(columns)):
                col = columns[i]
                left_rel = col["x"] - mon_geom["x"]
                if left_rel >= mon_geom["width"] - 100:
                    show_right = True
                    break
            
            if show_right:
                nr_appid = columns[focused_idx + 1]["appid"]
                nr_title = columns[focused_idx + 1]["title"]

        left_icon = " 󰁍 " if show_left else ""
        right_icon = " 󰁔 " if show_right else ""

        write_state(left_icon, right_icon, nl_appid, nl_title, nr_appid, nr_title)
        signal_waybar()

    # Read events line-by-line using non-blocking read & select for batching
    import select
    import fcntl

    # Make proc.stdout non-blocking
    fd = proc.stdout.fileno()
    fl = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

    buffer = ""
    try:
        while True:
            # Wait for data to be available (timeout=0.5s to keep loop responsive)
            r, _, _ = select.select([proc.stdout], [], [], 0.5)
            if not r:
                continue

            # Read all available data from the pipe
            data = ""
            while True:
                try:
                    chunk = proc.stdout.read(4096)
                    if not chunk:
                        break
                    data += chunk
                except BlockingIOError:
                    break

            if not data:
                break

            buffer += data
            lines = buffer.split("\n")
            buffer = lines[-1]
            lines = lines[:-1]

            if not lines:
                continue

            state_changed = False
            for line in lines:
                parts = line.strip().split(maxsplit=2)
                if len(parts) < 3:
                    continue
                mon, field, val = parts[0], parts[1], parts[2]

                if field == "selmon":
                    monitors_focus[mon] = (val == "1")
                    if val == "1":
                        active_monitor = mon
                        monitors_geom.clear()
                        monitors_geom.update(get_monitors_geometry())
                        state_changed = True
                elif mon == active_monitor:
                    if field == "tag":
                        t_parts = val.split()
                        if len(t_parts) >= 3:
                            tag_num = int(t_parts[0])
                            state_val = int(t_parts[1])
                            if state_val & 1:
                                if active_tag != tag_num:
                                    active_tag = tag_num
                                    focused_title = ""
                                    focused_appid = ""
                                    state_changed = True
                    elif field == "tags":
                        t_parts = val.split()
                        if len(t_parts) >= 2 and len(t_parts[0]) != 9:
                            try:
                                sel_mask = int(t_parts[1])
                                for bit in range(9):
                                    if sel_mask & (1 << bit):
                                        tag_num = bit + 1
                                        if active_tag != tag_num:
                                            active_tag = tag_num
                                            focused_title = ""
                                            focused_appid = ""
                                            state_changed = True
                                        break
                            except ValueError:
                                pass
                    elif field == "layout":
                        if layout != val:
                            layout = val
                            state_changed = True
                    elif field == "title":
                        if focused_title != val:
                            focused_title = val
                            state_changed = True
                    elif field == "appid":
                        if focused_appid != val:
                            focused_appid = val
                            state_changed = True
                    elif field == "x":
                        try:
                            x_val = int(val)
                            if focused_x != x_val:
                                focused_x = x_val
                                state_changed = True
                        except ValueError:
                            pass
                    elif field == "width":
                        try:
                            w_val = int(val)
                            if focused_w != w_val:
                                focused_w = w_val
                                state_changed = True
                        except ValueError:
                            pass
                    elif field == "clients":
                        state_changed = True

            if state_changed:
                update_indicators()
    except KeyboardInterrupt:
        pass
    finally:
        proc.terminate()

if __name__ == "__main__":
    def sig_handler(signum, frame):
        sys.exit(0)
    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)
    main()
