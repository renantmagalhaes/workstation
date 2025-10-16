#!/usr/bin/env python3
import asyncio
import subprocess
import json
import time
import argparse
import os
import sys
from evdev import InputDevice, UInput, ecodes as EC


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

    def edge_for(self, x, y, mt, mb, en_top, en_bottom):
        self.refresh()
        for (mx, my, mw, mh) in self._cache:
            if mx <= x < mx + mw and my <= y < my + mh:
                if en_top and y <= my + mt:
                    return "top"
                if en_bottom and y >= my + mh - mb:
                    return "bottom"
        return None


def make_uinput(use_shift_for_plus=False):
    keys = {EC.KEY_LEFTCTRL, EC.KEY_MINUS, EC.KEY_EQUAL}
    if use_shift_for_plus:
        keys.add(EC.KEY_LEFTSHIFT)
    return UInput({EC.EV_KEY: list(keys)}, name="edge-virtual-kbd", bustype=0x03)


def press_combo(ui, codes):
    # press then release in reverse
    for c in codes:
        ui.write(EC.EV_KEY, c, 1)
    ui.syn()
    for c in reversed(codes):
        ui.write(EC.EV_KEY, c, 0)
    ui.syn()


async def main():
    ap = argparse.ArgumentParser(
        description="Edge scroll (top/bottom) + side scroll => Ctrl±")
    ap.add_argument("--device", default="/dev/input/event8")
    ap.add_argument("--margin-top", type=int, default=12)
    ap.add_argument("--margin-bottom", type=int, default=12)
    ap.add_argument("--debounce-ms", type=int, default=120)
    ap.add_argument(
        "--top-cmd-up",   default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument(
        "--top-cmd-down", default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))
    ap.add_argument("--bottom-cmd-up",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument("--bottom-cmd-down",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))
    ap.add_argument("--enable-top", action="store_true", default=True)
    ap.add_argument("--enable-bottom", action="store_true", default=True)
    ap.add_argument("--invert-hwheel", action="store_true",
                    help="swap left/right meanings")
    ap.add_argument("--use-shift-for-plus", action="store_true",
                    help="send Ctrl+Shift+= instead of Ctrl+= for '+' on non-US layouts")
    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    try:
        dev = InputDevice(args.device)
    except Exception as err:
        print(f"Failed to open {args.device}: {err}", file=sys.stderr)
        print("Fix permissions (group input) or run once with sudo.", file=sys.stderr)
        sys.exit(1)

    try:
        ui = make_uinput(args.use_shift_for_plus)
    except Exception as err:
        print(f"Failed to open /dev/uinput: {err}", file=sys.stderr)
        print(
            "Add your user to group input or add a udev rule for uinput.", file=sys.stderr)
        sys.exit(1)

    monmap = MonitorMap()
    last_ts = 0.0
    debounce = args.debounce_ms / 1000.0

    REL_WHEEL_HI_RES = getattr(EC, "REL_WHEEL_HI_RES", 11)
    REL_HWHEEL_HI_RES = getattr(EC, "REL_HWHEEL_HI_RES", 12)

    if args.debug:
        print(
            f"[edge] device={args.device} margins T={args.margin_top} B={args.margin_bottom} debounce={args.debounce_ms}ms", file=sys.stderr)

    async for ev in dev.async_read_loop():
        # Side scroll -> Ctrl±
        if ev.type == EC.EV_REL and ev.code in (EC.REL_HWHEEL, REL_HWHEEL_HI_RES):
            v = ev.value
            if ev.code == REL_HWHEEL_HI_RES:
                v = -1 if v < 0 else (1 if v > 0 else 0)
            if args.invert_hwheel:
                v = -v

            if v < 0:
                # left  -> Ctrl + '+'
                seq = [EC.KEY_LEFTCTRL]
                if args.use_shift_for_plus:
                    seq.append(EC.KEY_LEFTSHIFT)
                seq.append(EC.KEY_EQUAL)
                press_combo(ui, seq)
                if args.debug:
                    print("[edge] hwheel left  -> Ctrl++", file=sys.stderr)

            elif v > 0:
                # right -> Ctrl + '-'
                press_combo(ui, [EC.KEY_LEFTCTRL, EC.KEY_MINUS])
                if args.debug:
                    print("[edge] hwheel right -> Ctrl+-", file=sys.stderr)
            continue

        # Vertical wheel -> edge actions
        if ev.type != EC.EV_REL or ev.code not in (EC.REL_WHEEL, REL_WHEEL_HI_RES):
            continue
        v = ev.value
        if ev.code == REL_WHEEL_HI_RES:
            v = -1 if v < 0 else (1 if v > 0 else 0)
        if v == 0:
            continue

        now = time.monotonic()
        if now - last_ts < debounce:
            continue
        last_ts = now

        try:
            x, y = cursor_xy()
        except Exception as err:
            if args.debug:
                print(f"[edge] hyprctl failed: {err}", file=sys.stderr)
            continue

        which = monmap.edge_for(
            x, y, args.margin_top, args.margin_bottom, args.enable_top, args.enable_bottom)
        if args.debug:
            print(
                f"[edge] wheel={v} at x={x} y={y} edge={which}", file=sys.stderr)
        if not which:
            continue

        cmd = (args.top_cmd_up if v < 0 else args.top_cmd_down) if which == "top" \
            else (args.bottom_cmd_up if v < 0 else args.bottom_cmd_down)
        if args.debug:
            print(f"[edge] run: {cmd}", file=sys.stderr)
        subprocess.Popen(["bash", "-lc", cmd])

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
