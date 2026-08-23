#!/usr/bin/env python3
"""
listen-scroll.py

Watches input devices and shows the exact raw wheel events your REAL mouse
produces when you scroll. Use this as a reference: the output tells us the
precise device + event codes that scroll a page, so we can make sure
sound-scroller.py emits the identical thing.

Use cases
---------
  1. Scroll your normal physical mouse wheel while this runs. It prints the
     device and the EV_REL / REL_WHEEL (+ HI_RES) values of every scroll.
  2. Then run sound-scroller.py or trigger-scroll.py in parallel and turn
     the knob. If our virtual device appears in this output too, we can
     compare its numbers against the real mouse and spot any mismatch.

Usage
-----
  sudo python3 listen-scroll.py                     # watch all devices
  sudo python3 listen-scroll.py --device /dev/input/event3
  sudo python3 listen-scroll.py --no-hires          # ignore high-res deltas
"""

import argparse
import glob
import logging
import os
import select
import sys

try:
    from evdev import InputDevice
    from evdev import ecodes as E
except ImportError as exc:
    print("Missing dependency 'evdev'. Install with:",
          "sudo apt install python3-evdev", file=sys.stderr)
    raise SystemExit(1) from exc

log = logging.getLogger("listen-scroll")


def open_dev(p: str) -> InputDevice | None:
    try:
        return InputDevice(p)
    except (OSError, PermissionError):
        return None


def all_devices() -> list[tuple[str, str]]:
    """Return (path, name) for every readable input device, by-id first."""
    seen: set[str] = set()
    out: list[tuple[str, str]] = []
    for symlink in sorted(glob.glob("/dev/input/by-id/*-event*")):
        try:
            real = os.path.realpath(symlink)
        except OSError:
            continue
        if real in seen:
            continue
        seen.add(real)
        dev = open_dev(symlink)
        if dev is not None:
            out.append((symlink, dev.name or real))
            dev.close()
    for event in sorted(glob.glob("/dev/input/event*")):
        if event in seen:
            continue
        seen.add(event)
        dev = open_dev(event)
        if dev is not None:
            out.append((event, dev.name or event))
            dev.close()
    return out


def is_scroll(code: int) -> bool:
    return code in (E.REL_WHEEL, E.REL_HWHEEL,
                    E.REL_WHEEL_HI_RES, E.REL_HWHEEL_HI_RES)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="listen-scroll", description=__doc__)
    p.add_argument("--device", help="Only watch this one /dev/input/eventX.")
    p.add_argument("--no-hires", action="store_true",
                   help="Ignore high-res deltas (REL_WHEEL_HI_RES etc.).")
    p.add_argument("--all-events", action="store_true",
                   help="Show every EV_REL event, not just wheel axes.")
    args = p.parse_args(argv)

    logging.basicConfig(level=logging.INFO,
                        format="%(levelname)s: %(message)s")

    if args.device:
        devs = [open_dev(args.device)]
        if devs[0] is None:
            raise SystemExit(f"cannot open {args.device}")
    else:
        devs = [open_dev(path) for path, _ in all_devices()]
        devs = [d for d in devs if d is not None]

    if not devs:
        raise SystemExit("no readable devices; run with sudo?")

    print(f"Listening on {len(devs)} device(s). Scroll your real mouse wheel;\n"
          "the raw wheel events will be printed. Ctrl-C to quit.\n")

    WHEEL = {E.REL_WHEEL: "REL_WHEEL", E.REL_HWHEEL: "REL_HWHEEL",
             E.REL_WHEEL_HI_RES: "REL_WHEEL_HI_RES",
             E.REL_HWHEEL_HI_RES: "REL_HWHEEL_HI_RES"}
    REL = {getattr(E, n): n for n in dir(E) if n.startswith("REL_")}

    try:
        while True:
            r, _, _ = select.select(devs, [], [], 1.0)
            for dev in r:
                for ev in dev.read():
                    if ev.type != E.EV_REL:
                        continue
                    name = REL.get(ev.code, f"REL_0x{ev.code:x}")
                    if is_scroll(ev.code):
                        print(f"[{dev.path}] {dev.name}\n"
                              f"    {name:20s} value={ev.value:+d}")
                    elif args.all_events:
                        print(f"[{dev.path}] {dev.name}\n"
                              f"    {name:20s} value={ev.value:+d}  (other)")
    except KeyboardInterrupt:
        print("\nstopped.")
    finally:
        for d in devs:
            d.close()

    return 0


if __name__ == "__main__":
    sys.exit(main())
