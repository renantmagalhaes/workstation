#!/usr/bin/env python3
import asyncio
import subprocess
import json
import time
import argparse
import os
import sys
import logging
import signal
import shlex
from evdev import InputDevice, ecodes as EC, list_devices

def setup_logging(debug=False):
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler(sys.stderr)]
    )
    return logging.getLogger(__name__)

def run_command(cmd, timeout=5):
    try:
        out = subprocess.check_output(cmd, text=True, timeout=timeout, stderr=subprocess.DEVNULL)
        return out
    except Exception as e:
        raise Exception(f"Command failed: {cmd} - {e}")

def get_desktop_count(logger):
    try:
        # qdbus6 often segfaults on /VirtualDesktopManager, so use dbus-send
        cmd = [
            "dbus-send", "--session", "--print-reply",
            "--dest=org.kde.KWin", "/VirtualDesktopManager",
            "org.freedesktop.DBus.Properties.Get",
            "string:org.kde.KWin.VirtualDesktopManager", "string:count"
        ]
        out = run_command(cmd)
        for line in out.splitlines():
            if "uint32" in line:
                return int(line.split()[-1])
    except Exception as e:
        logger.error(f"Failed to get desktop count: {e}")
    return 1

def get_current_desktop(logger):
    try:
        # This one is usually safe with qdbus6, but let's be consistent or keep it if it works
        # The user's log showed only count failing.
        out = run_command(["qdbus6", "org.kde.KWin", "/KWin", "org.kde.KWin.currentDesktop"])
        return int(out.strip())
    except Exception as e:
        logger.error(f"Failed to get current desktop: {e}")
        return 1

class VirtualCursor:
    def __init__(self, logger, sensitivity=1.0):
        self.logger = logger
        self.sensitivity = sensitivity
        self.x = 0
        self.y = 0
        self.min_x = 0
        self.min_y = 0
        self.max_x = 1920
        self.max_y = 1080
        self.monitors = []
        self.margin = 12

    def refresh_monitors(self):
        try:
            out = run_command(["kscreen-doctor", "-j"])
            j = json.loads(out)
            self.monitors = []
            for output in j.get("outputs", []):
                if output.get("enabled"):
                    pos = output.get("pos", {})
                    size = output.get("size", {})
                    if pos and size:
                        self.monitors.append((int(pos["x"]), int(pos["y"]), int(size["width"]), int(size["height"])))
            
            if self.monitors:
                self.min_x = min(m[0] for m in self.monitors)
                self.min_y = min(m[1] for m in self.monitors)
                self.max_x = max(m[0] + m[2] for m in self.monitors)
                self.max_y = max(m[1] + m[3] for m in self.monitors)
                self.logger.info(f"Monitor Area: ({self.min_x},{self.min_y}) to ({self.max_x},{self.max_y})")
        except Exception as e:
            self.logger.error(f"Failed to refresh monitors: {e}")

    def move(self, dx, dy):
        self.x += dx * self.sensitivity
        self.y += dy * self.sensitivity
        # Clamp to virtual desktop bounds
        self.x = max(self.min_x, min(self.max_x - 1, self.x))
        self.y = max(self.min_y, min(self.max_y - 1, self.y))

    def get_edge(self):
        # We need to find which monitor the virtual cursor is on
        for (mx, my, mw, mh) in self.monitors:
            if mx <= self.x < mx + mw and my <= self.y < my + mh:
                if self.y <= my + self.margin:
                    return "top"
                if self.y >= my + mh - self.margin:
                    return "bottom"
        return "none"

    def sync_to_top_left(self):
        self.x = self.min_x
        self.y = self.min_y
        self.logger.info("Coordinates synced to Top-Left")

async def handle_device(dev, args, logger, vc):
    logger.info(f"Monitoring: {dev.name} ({dev.path})")
    
    last_vert_ts = 0.0
    last_right_click_ts = 0.0
    REL_WHEEL_HI_RES = getattr(EC, "REL_WHEEL_HI_RES", 11)

    async for ev in dev.async_read_loop():
        now = time.monotonic()
        
        # 1. Track Movement
        if ev.type == EC.EV_REL:
            if ev.code == EC.REL_X:
                vc.move(ev.value, 0)
            elif ev.code == EC.REL_Y:
                vc.move(0, ev.value)
            
            # 2. Track Vertical Wheel
            elif ev.code in (EC.REL_WHEEL, REL_WHEEL_HI_RES):
                v = ev.value
                if ev.code == REL_WHEEL_HI_RES: v = -1 if v < 0 else (1 if v > 0 else 0)
                if v == 0: continue
                
                if now - last_vert_ts < (args.debounce_ms / 1000.0): continue
                last_vert_ts = now
                
                edge = vc.get_edge()
                if edge != "none":
                    logger.info(f"Wheel {v} at Virtual({int(vc.x)}, {int(vc.y)}) -> Edge: {edge}")
                    try:
                        # Get current desktop index and total count to prevent wrapping
                        current = get_current_desktop(logger)
                        total = get_desktop_count(logger)
                        
                        if v < 0: # Scroll up -> nextDesktop
                            if current < total:
                                logger.info(f"Virtual Edge {edge} scroll UP -> nextDesktop (current: {current}/{total})")
                                subprocess.Popen(["qdbus6", "org.kde.KWin", "/KWin", "org.kde.KWin.nextDesktop"], stderr=subprocess.DEVNULL)
                            else:
                                logger.debug(f"At last desktop ({current}/{total}), stopping.")
                        else: # Scroll down -> previousDesktop
                            if current > 1:
                                logger.info(f"Virtual Edge {edge} scroll DOWN -> previousDesktop (current: {current}/{total})")
                                subprocess.Popen(["qdbus6", "org.kde.KWin", "/KWin", "org.kde.KWin.previousDesktop"], stderr=subprocess.DEVNULL)
                            else:
                                logger.debug(f"At first desktop ({current}/{total}), stopping.")
                    except Exception as e:
                        logger.error(f"Desktop switch error: {e}")

        # 3. Track Right Click
        elif ev.type == EC.EV_KEY and ev.code == EC.BTN_RIGHT and ev.value == 1:
            if now - last_right_click_ts < (args.right_click_debounce_ms / 1000.0): continue
            last_right_click_ts = now
            
            edge = vc.get_edge()
            if edge != "none":
                logger.info(f"Virtual Edge {edge} right-click -> {args.right_click_cmd}")
                subprocess.Popen(["bash", "-lc", args.right_click_cmd], stderr=subprocess.DEVNULL)

def get_all_mice():
    mice = []
    for path in list_devices():
        try:
            dev = InputDevice(path)
            caps = dev.capabilities()
            if EC.EV_REL in caps or EC.EV_KEY in caps:
                mice.append(dev)
        except Exception:
            continue
    return mice

async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sensitivity", type=float, default=1.0, help="Sensitivity for virtual cursor tracking (default 1.0)")
    ap.add_argument("--debounce-ms", type=int, default=100)
    ap.add_argument("--right-click-cmd", default="jgmenu --at-pointer")
    ap.add_argument("--right-click-debounce-ms", type=int, default=300)
    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    logger = setup_logging(args.debug)
    logger.info(f"DBUS_SESSION_BUS_ADDRESS: {os.environ.get('DBUS_SESSION_BUS_ADDRESS')}")
    
    vc = VirtualCursor(logger, args.sensitivity)
    vc.refresh_monitors()
    
    mice = get_all_mice()
    if not mice:
        logger.error("No input devices found.")
        sys.exit(1)
        
    logger.info(f"Initialized. Detected {len(mice)} devices.")
    print("\n" + "="*60)
    print("ACTION REQUIRED: Move your mouse to the TOP-LEFT corner once.")
    print("This will sync the virtual cursor with your screen edges.")
    print("="*60 + "\n")
    
    # Sync after a small delay to allow user to move
    asyncio.get_event_loop().call_later(2, vc.sync_to_top_left)

    tasks = [handle_device(m, args, logger, vc) for m in mice]
    await asyncio.gather(*tasks)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))
    signal.signal(signal.SIGTERM, lambda s, f: sys.exit(0))
    try:
        asyncio.run(main())
    except Exception as e:
        print(f"Error: {e}")
