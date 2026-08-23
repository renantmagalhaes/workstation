#!/usr/bin/env python3
"""
scroll-test.py

A tiny test/trigger helper for sound-scroller.py.

It creates the SAME virtual mouse device as sound-scroller.py and, when
invoked, emits one mouse-wheel step. Use it to confirm that the virtual
wheel device actually scrolls pages -- independent of the knob.

This isolates the two halves of the problem:
  * If THIS moves the page, then virtual-wheel emission works, and the
    issue is how the knob events are mapped (in sound-scroller.py).
  * If THIS does too NOT move the page, then the compositor is not
    accepting our virtual mouse at all (e.g. Wayland restrictions), and
    no knob script will help until that is resolved.

Usage
-----
  sudo python3 trigger-scroll.py down
  sudo python3 trigger-scroll.py up
  sudo python3 trigger-scroll.py --repeat 5 --delay 0.1 down  # not implemented
  sudo python3 trigger-scroll.py --repeat 20 down             # scrolls more
"""

import argparse
import sys
import time

try:
    from evdev import UInput
    from evdev import ecodes as E
except ImportError as exc:
    print("Missing dependency 'evdev'. Install with:",
          "sudo apt install python3-evdev", file=sys.stderr)
    raise SystemExit(1) from exc


def create_virtual_mouse(name: str) -> UInput:
    """Same device description as sound-scroller.py so behavior matches."""
    capabilities = {
        E.EV_KEY: [E.BTN_LEFT, E.BTN_RIGHT, E.BTN_MIDDLE],
        E.EV_REL: [
            E.REL_X,                # so libinput treats it as a real mouse
            E.REL_Y,
            E.REL_WHEEL,
            E.REL_WHEEL_HI_RES,     # high-res reset each step
            E.REL_HWHEEL,
            E.REL_HWHEEL_HI_RES,
        ],
    }
    desc = {
        "name": name,
        "vendor": 0x1234,
        "product": 0x5678,
        "version": 1,
        "bustype": E.BUS_VIRTUAL,
    }
    return UInput(events=capabilities, **desc)


def main() -> int:
    p = argparse.ArgumentParser(
        prog="trigger-scroll",
        description="Emit a mouse-wheel step from the same virtual device "
                    "used by sound-scroller, to test page scrolling.",
    )
    p.add_argument("direction", nargs="?", choices=["up", "down"], default="down",
                   help="Which way to scroll (default: down).")
    p.add_argument("--repeat", type=int, default=1,
                   help="Number of wheel steps to emit (default: 1).")
    p.add_argument("--listen", action="store_true",
                   help="stay running and keep scrolling every 2s (for live test).")
    args = p.parse_args()

    step = -1 if args.direction == "down" else +1

    ui = create_virtual_mouse("sound-scroller virtual mouse")
    print(f"virtual mouse ready; emitting {args.repeat} x "
          f"{args.direction} wheel step{'s' * (args.repeat > 1)}",
          flush=True)
    try:
        while True:
            for _ in range(args.repeat):
                ui.write(E.EV_REL, E.REL_WHEEL, step)
                ui.write(E.EV_REL, E.REL_WHEEL_HI_RES, step * 120)
                ui.syn()
            print("  scroll event sent")
            if not args.listen:
                break
            time.sleep(2)
    except KeyboardInterrupt:
        print("\nstopped")
    finally:
        ui.destroy()

    return 0


if __name__ == "__main__":
    sys.exit(main())
