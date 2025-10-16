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
    for c in codes:
        ui.write(EC.EV_KEY, c, 1)
    ui.syn()
    for c in reversed(codes):
        ui.write(EC.EV_KEY, c, 0)
    ui.syn()


async def main():
    ap = argparse.ArgumentParser(
        description="Edge scroll (top/bottom) + side scroll => Ctrl± with separate debounces")
    ap.add_argument("--device", default="/dev/input/event8")
    ap.add_argument("--margin-top", type=int, default=12)
    ap.add_argument("--margin-bottom", type=int, default=12)

    # Vertical (edge actions) debounce
    ap.add_argument("--debounce-ms", type=int, default=80,
                    help="vertical wheel debounce for edge actions (ms)")
    # Horizontal (zoom) debounce
    ap.add_argument("--horiz-debounce-ms", type=int, default=20,
                    help="horizontal wheel debounce for Ctrl± (ms)")

    # Edge commands
    ap.add_argument(
        "--top-cmd-up",   default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument(
        "--top-cmd-down", default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))
    ap.add_argument("--bottom-cmd-up",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh next"))
    ap.add_argument("--bottom-cmd-down",
                    default=os.path.expanduser("~/.config/hypr/scripts/wpairswitch.sh prev"))

    # Edges enabled by default; disable with --no-top or --no-bottom
    ap.add_argument("--top", dest="enable_top",
                    action="store_true", default=True)
    ap.add_argument("--no-top", dest="enable_top", action="store_false")
    ap.add_argument("--bottom", dest="enable_bottom",
                    action="store_true", default=True)
    ap.add_argument("--no-bottom", dest="enable_bottom", action="store_false")

    # Side scroll options
    ap.add_argument("--invert-hwheel", action="store_true",
                    help="swap left and right meanings")
    ap.add_argument("--use-shift-for-plus", action="store_true",
                    help="send Ctrl+Shift+= instead of Ctrl+= if your layout needs Shift for '+'")

    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    # Open devices
    try:
        dev = InputDevice(args.device)
    except Exception as err:
        print(f"Failed to open {args.device}: {err}", file=sys.stderr)
        print("Fix permissions for /dev/input/event*, or run once with sudo, then add user to 'input' group.", file=sys.stderr)
        sys.exit(1)

    try:
        ui = make_uinput(args.use_shift_for_plus)
    except Exception as err:
        print(f"Failed to open /dev/uinput: {err}", file=sys.stderr)
        print("Ensure /dev/uinput is group 'input' and you are in that group, or create a udev rule.", file=sys.stderr)
        sys.exit(1)

    monmap = MonitorMap()

    # Separate clocks for debouncing
    last_vert_ts = 0.0
    last_horiz_ts = 0.0
    debounce_vert = args.debounce_ms / 1000.0
    debounce_horiz = args.horiz_debounce_ms / 1000.0

    REL_WHEEL_HI_RES = getattr(EC, "REL_WHEEL_HI_RES", 11)
    REL_HWHEEL_HI_RES = getattr(EC, "REL_HWHEEL_HI_RES", 12)

    if args.debug:
        print(f"[edge] device={args.device} Tmargin={args.margin_top} Bmargin={args.margin_bottom} "
              f"vert_debounce={debounce_vert}s horiz_debounce={debounce_horiz}s "
              f"top_enabled={args.enable_top} bottom_enabled={args.enable_bottom}", file=sys.stderr)

    async for ev in dev.async_read_loop():
        # ---------- Horizontal wheel => Ctrl± with its own debounce ----------
        if ev.type == EC.EV_REL and ev.code in (EC.REL_HWHEEL, REL_HWHEEL_HI_RES):
            v = ev.value
            if ev.code == REL_HWHEEL_HI_RES:
                v = -1 if v < 0 else (1 if v > 0 else 0)
            if args.invert_hwheel:
                v = -v

            now = time.monotonic()
            if now - last_horiz_ts < debounce_horiz:
                if args.debug:
                    print("[edge] horiz debounced", file=sys.stderr)
                continue
            last_horiz_ts = now

            if v < 0:
                seq = [EC.KEY_LEFTCTRL]
                if args.use_shift_for_plus:
                    seq.append(EC.KEY_LEFTSHIFT)
                seq.append(EC.KEY_EQUAL)    # '+' with shift on many layouts
                press_combo(ui, seq)
                if args.debug:
                    print("[edge] hwheel left  -> Ctrl++", file=sys.stderr)
            elif v > 0:
                press_combo(ui, [EC.KEY_LEFTCTRL, EC.KEY_MINUS])
                if args.debug:
                    print("[edge] hwheel right -> Ctrl+-", file=sys.stderr)
            continue

        # ---------- Vertical wheel => edge actions with its debounce ----------
        if ev.type != EC.EV_REL or ev.code not in (EC.REL_WHEEL, REL_WHEEL_HI_RES):
            continue

        v = ev.value
        if ev.code == REL_WHEEL_HI_RES:
            v = -1 if v < 0 else (1 if v > 0 else 0)
        if v == 0:
            continue

        now = time.monotonic()
        if now - last_vert_ts < debounce_vert:
            if args.debug:
                print("[edge] vert debounced", file=sys.stderr)
            continue
        last_vert_ts = now

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
                f"[edge] vert wheel={v} at x={x} y={y} edge={which}", file=sys.stderr)
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
