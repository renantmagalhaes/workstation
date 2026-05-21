#!/usr/bin/env python3
import subprocess

def get_active_monitor_info():
    try:
        output = subprocess.check_output(["mmsg", "-g"], text=True)
    except Exception:
        return None
    
    # Find the active monitor (selmon 1)
    active_mon = None
    for line in output.splitlines():
        parts = line.strip().split()
        if len(parts) >= 3 and parts[1] == "selmon" and parts[2] == "1":
            active_mon = parts[0]
            break
            
    if not active_mon:
        return None
        
    mon_info = {
        "layout": "",
        "clients": 0,
        "tag_clients": {},
        "active_tag": 1
    }
    
    for line in output.splitlines():
        parts = line.strip().split(maxsplit=2)
        if len(parts) < 3 or parts[0] != active_mon:
            continue
        field, val = parts[1], parts[2]
        if field == "layout":
            mon_info["layout"] = val
        elif field == "clients":
            mon_info["clients"] = int(val)
        elif field == "tag":
            t_parts = val.split()
            if len(t_parts) >= 3:
                tag_num = int(t_parts[0])
                state_val = int(t_parts[1])
                clients = int(t_parts[2])
                mon_info["tag_clients"][tag_num] = clients
                if state_val & 1:
                    mon_info["active_tag"] = tag_num
        elif field == "tags":
            t_parts = val.split()
            if len(t_parts) >= 2:
                if len(t_parts[0]) == 9:
                    continue
                try:
                    sel_mask = int(t_parts[1])
                    for bit in range(9):
                        if sel_mask & (1 << bit):
                            mon_info["active_tag"] = bit + 1
                            break
                except ValueError:
                    pass
                    
    return mon_info

def main():
    info = get_active_monitor_info()
    if not info:
        return
        
    C = info["tag_clients"].get(info["active_tag"], 0)
    if C == 0 and info["clients"] > 0:
        C = info["clients"]
        
    # If layout is Scroller ("S") and clients on active tag >= 3
    if info["layout"] == "S" and C >= 3:
        print("󰁍 󰁔")
    else:
        print("")

if __name__ == "__main__":
    main()
