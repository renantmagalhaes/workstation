#!/usr/bin/env python3
import sys
import subprocess

def main():
    if len(sys.argv) < 2:
        return
    action = sys.argv[1].lower()
    
    if action == "left":
        path = "/tmp/mangowm_scroll_left"
        try:
            with open(path, "r") as f:
                print(f.read().strip())
        except Exception:
            print("")
    elif action == "right":
        path = "/tmp/mangowm_scroll_right"
        try:
            with open(path, "r") as f:
                print(f.read().strip())
        except Exception:
            print("")
    elif action in ("click_left", "click_right"):
        side = "left" if action == "click_left" else "right"
        try:
            with open(f"/tmp/mangowm_next_{side}_appid", "r") as f:
                appid = f.read().strip()
            with open(f"/tmp/mangowm_next_{side}_title", "r") as f:
                title = f.read().strip()
            
            if appid or title:
                cmd = ["wlrctl", "toplevel", "focus"]
                if appid:
                    cmd.append(f"app_id:{appid}")
                if title:
                    cmd.append(f"title:{title}")
                subprocess.run(cmd)
        except Exception:
            pass

if __name__ == "__main__":
    main()
