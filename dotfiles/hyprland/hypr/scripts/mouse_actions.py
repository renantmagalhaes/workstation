#!/usr/bin/env python3
import asyncio
import subprocess
import json
import time
import argparse
import os
import sys
from evdev import InputDevice, ecodes


def run_json(cmd):
    out = subprocess.check_output(cmd, text=True)
    return json.loads(out)


def cursor_xy():
    j = run_json(["hyprctl", "cursorpos", "-j"])
    return int(j["x"]), int(j["y"])


class MonitorMap:
    def __init__(self):
        self._last = 0.0
        self._cache = []

    def refresh(self, max_age=5.0):
        now = time.monotonic()
        if now - self._last > max_age or not self._cache:
            j = run_json(["hyprctl", "monitors", "-j"])
            self._cache = [(int(m["x"]), int(m["y"]), int(
                m["width"]), int(m["height"])) for m in j]
            self._last = now

    def edge_for(self, x, y, margin_top, margin_bottom, enable_top, enable_bottom):
        """Return 'top' or 'bottom' if cursor is within that edge on its current monitor, else None."""
        self.refresh()
        for (mx, my, mw, mh) in self._cache:
            if mx <= x < mx + mw and my <= y < my + mh:
                if enable_top and y <= my + margin_top:
                    return "top"
                if enable_bottom and y >= my + mh - margin_bottom:
                    return "bottom"
        return None


async def main():
    ap = argparse.ArgumentParser(
        description="Hyprland edge scroll trigger (top and bottom)")
    ap.add_argument("--device", default="/dev/input/event8",
                    help="input event node with REL_WHEEL")
    ap.add_argument("--margin-top", type=int, default=12,
                    help="pixels from top edge")
    ap.add_argument("--margin-bottom", type=int, default=12,
                    help="pixels from bottom edge")
    ap.add_argument("--debounce-ms", type=int, default=120)

    # Top edge commands
    ap.add_argument(
        "--top-cmd-up",   default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument(
        "--top-cmd-down", default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))

    # Bottom edge commands
    ap.add_argument("--bottom-cmd-up",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument("--bottom-cmd-down",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))

    ap.add_argument("--enable-top", action="store_true", default=True)
    ap.add_argument("--enable-bottom", action="store_true", default=True)
    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    try:
        dev = InputDevice(args.device)
    except Exception as e:
        print(f"Failed to open {args.device}. {e}", file=sys.stderr)
        print("You likely need permission to read the input device. Use sudo once to confirm, then add your user to group input.", file=sys.stderr)
        sys.exit(1)

    monmap = MonitorMap()
    last_ts = 0.0
    debounce = args.debounce_ms / 1000.0
    REL_WHEEL_HI_RES = getattr(ecodes, "REL_WHEEL_HI_RES", 11)

    if args.debug:
        print(f"[edge] device={args.device} top={args.enable_top} bottom={args.enable_bottom} "
              f"margins T={args.margin_top} B={args.margin_bottom} debounce={args.debounce_ms}ms", file=sys.stderr)

    async for ev in dev.async_read_loop():
        if ev.type != ecodes.EV_REL:
            continue
        if ev.code not in (ecodes.REL_WHEEL, REL_WHEEL_HI_RES):
            continue

        # Normalize sign only
        value = ev.value
        if ev.code == REL_WHEEL_HI_RES:
            value = -1 if value < 0 else (1 if value > 0 else 0)
        if value == 0:
            continue

        now = time.monotonic()
        if now - last_ts < debounce:
            continue
        last_ts = now

        try:
            x, y = cursor_xy()
        except Exception as e:
            if args.debug:
                print(f"[edge] hyprctl failed: {e}", file=sys.stderr)
            continue

        which = monmap.edge_for(
            x, y, args.margin_top, args.margin_bottom, args.enable_top, args.enable_bottom)
        if args.debug:
            print(
                f"[edge] wheel={value} at x={x} y={y} edge={which}", file=sys.stderr)
        if not which:
            continue

        # Choose command by edge and direction
        if which == "top":
            cmd = args.top_cmd_up if value < 0 else args.top_cmd_down
        else:
            cmd = args.bottom_cmd_up if value < 0 else args.bottom_cmd_down

        if args.debug:
            print(f"[edge] run: {cmd}", file=sys.stderr)
        subprocess.Popen(["bash", "-lc", cmd])

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
