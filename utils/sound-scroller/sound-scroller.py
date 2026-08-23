#!/usr/bin/env python3
"""
sound-scroller.py

Turns a knob that currently sends *volume* input events into a page
scroller: instead of adjusting volume, its rotation scrolls the active
window (mouse wheel up / down).

Requirements
------------
  * Linux (uses /dev/input and uinput)
  * python3-evdev

      # Debian / Ubuntu
      sudo apt install python3-evdev
      # or
      python3 -m pip install evdev

  * The knob must be visible as an input device, e.g. /dev/input/eventX.

Typical usage
-------------
  # Just run it: the script watches ALL input devices, asks you to turn
  # the knob, and identifies the device automatically from the activity.
  sudo python3 sound-scroller.py

  # Auto-select the first device whose name contains 'knob'
  sudo python3 sound-scroller.py --name knob

  # Exact device path (no discovery)
  sudo python3 sound-scroller.py --device /dev/input/event7

  # Double scroll speed: 1 knob detent = 2 wheel notches
  sudo python3 sound-scroller.py --pace 2

  # Show the numbered selection menu instead of sniffing
  sudo python3 sound-scroller.py --menu

Direction
---------
Default (natural):  rotating right scrolls down, rotating left scrolls up.
If it feels inverted, add --flip.
"""

import argparse
import glob
import logging
import os
import select
import sys
import time

try:
    from evdev import InputDevice, UInput
    from evdev import ecodes as E
except ImportError as exc:  # pragma: no cover
    print(
        "Missing dependency 'evdev'. Install with:\n"
        "  sudo apt install python3-evdev     (or:  pip install evdev)",
        file=sys.stderr,
    )
    raise SystemExit(1) from exc

log = logging.getLogger("sound-scroller")

# Map the knob's key events to a vertical scroll step.
#
# Most wireless knobs report KEY_VOLUMEUP when rotated right and
# KEY_VOLUMEDOWN when rotated left. We then re-emit them as wheel motion.
#
# Default (natural) mapping: rotate right -> scroll down, rotate left -> up.
#   KEY_VOLUMEUP   maps to REL_WHEEL -1   (scroll down)
#   KEY_VOLUMEDOWN maps to REL_WHEEL +1   (scroll up)
#
# If your knob reports other codes (KEY_WHEEL, KEY_NEXT/KEY_PREVIOUS, ...),
# add them here.
SCROLL_KEYS = {
    E.KEY_VOLUMEUP: -1,
    E.KEY_VOLUMEDOWN: +1,
}

# ---------------------------------------------------------------------------
# CONFIG (edit these to change behaviour) ----------------------------------
# ---------------------------------------------------------------------------

# Scroll pace: how many wheel notches each knob detent equals.
#   1 = 1:1 (default, one knob notch -> one wheel notch)
#   2 = twice as fast, 3 = three times, etc.
# Can be overridden at runtime with `--pace`.
PACE = 5


def create_virtual_mouse(name: str) -> UInput:
    """Create a virtual device that acts as a real mouse emitting wheel motion.

    It advertises pointer buttons plus relative motion (X/Y and both wheels)
    so libinput classifies it as a genuine mouse. A device that only exposes
    REL_WHEEL is often ignored by the compositor's pointer stack.
    """
    capabilities = {
        E.EV_KEY: [
            E.BTN_LEFT,
            E.BTN_RIGHT,
            E.BTN_MIDDLE,
        ],
        E.EV_REL: [
            E.REL_X,  # so it looks like a real pointer
            E.REL_Y,
            E.REL_WHEEL,
            E.REL_WHEEL_HI_RES,
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


def _open_dev(p: str) -> InputDevice | None:
    """Open an input path, returning None on permission/IO errors."""
    try:
        return InputDevice(p)
    except (OSError, PermissionError):
        return None


def _uses_volume_keys(dev: InputDevice) -> bool:
    """Return True if this device reports any of our SCROLL_KEYS codes."""
    try:
        codes = dev.capabilities(verbose=False).get(E.EV_KEY, [])
    except OSError:
        return False
    return bool(codes) and any(c in SCROLL_KEYS for c in codes)


def enumerate_candidates() -> list[tuple[str, str, bool]]:
    """Return (path, name, has_volume_keys) for every readable input device."""
    seen: set[str] = set()
    out: list[tuple[str, str, bool]] = []

    # Prefer /dev/input/by-id/ names because they are human-meaningful.
    for symlink in sorted(glob.glob("/dev/input/by-id/*-event*")):
        try:
            real = os.path.realpath(symlink)
        except OSError:
            continue
        if real in seen:
            continue
        seen.add(real)
        dev = _open_dev(symlink)
        if dev is not None:
            out.append((symlink, dev.name or real, _uses_volume_keys(dev)))
            dev.close()

    for event in sorted(glob.glob("/dev/input/event*")):
        if event in seen:
            continue
        seen.add(event)
        dev = _open_dev(event)
        if dev is not None:
            out.append((event, dev.name or event, _uses_volume_keys(dev)))
            dev.close()

    # Most likely candidates first: devices that already speak volume keys.
    out.sort(key=lambda t: (not t[2], t[0].lower()))
    return out


def select_device(args) -> InputDevice:
    """Resolve the knob device: explicit path, name match, or interactive pick.

    Returns an open InputDevice.
    """
    # 1) Explicit path wins.
    if args.device:
        dev = _open_dev(args.device)
        if dev is None:
            raise SystemExit(f"cannot open input device: {args.device}")
        return dev

    candidates = enumerate_candidates()

    # 2) Auto-select if --name matched something.
    if args.name and args.name != "*":
        matches = [c for c in candidates if args.name.lower() in c[1].lower()]
        if matches:
            chosen = matches[0]
            log.info("matched %s (%s)", chosen[1], chosen[0])
            dev = _open_dev(chosen[0])
            if dev is None:
                raise SystemExit(f"cannot open {chosen[0]}")
            return dev

        # No name match: fall through to sniffing/menu below.

    # 3) When nothing explicit was given, offer to sniff the knob by turning it.
    if (
        not args.device
        and (args.name or "") == "*"
        and not getattr(args, "menu", False)
    ):
        print("No device specified — let's identify your knob.\n")
        sniffed = sniff_device(timeout=args.timeout)
        if sniffed is not None:
            return sniffed
        # sniff timed out or was cancelled; fall back to the picker.

    # 4) Otherwise show an interactive selection menu of all candidates.
    if not candidates:
        raise SystemExit(
            "No input devices found. Are you root / do you have read access?"
        )

    print("\nSelect the knob device to act as a mouse scroll wheel:\n")
    for i, (path, name, vol) in enumerate(candidates, 1):
        tag = "volume knob?" if vol else ""
        print(f"  {i:>2}. {name:<28} {path}  {tag}")
    print(f"  {len(candidates) + 1:>2}. Quit")

    while True:
        try:
            raw = input("\nEnter a number: ").strip()
        except (EOFError, KeyboardInterrupt):
            raise SystemExit("\nbye")
        if not raw:
            continue
        if raw.isdigit():
            n = int(raw)
            if n == len(candidates) + 1:
                raise SystemExit("bye")
            if 1 <= n <= len(candidates):
                path, name, _ = candidates[n - 1]
                log.info("selected %s (%s)", name, path)
                dev = _open_dev(path)
                if dev is None:
                    raise SystemExit(f"cannot open {path}")
                return dev
        print("  (invalid choice)")


def sniff_device(timeout: float = 30.0) -> InputDevice | None:
    """Find the knob by watching activity on every readable input device.

    All candidates are opened for reading; the user is asked to turn the
    knob, and the first device to report a key we recognize as knob motion
    (from SCROLL_KEYS, or a volume-style relative wheel) is returned.

    Note: we do NOT grab (EVIOCGRAB) any device here. Grabbing could
    exclusively swallow events for devices like a keyboard and lock the
    input until reboot. Reading events is enough and is safe.
    """
    candidates = enumerate_candidates()
    if not candidates:
        raise SystemExit("no readable input devices found (run as root?)")

    devs: list[InputDevice] = []
    try:
        for path, _, _ in candidates:
            dev = _open_dev(path)
            if dev is not None:
                devs.append(dev)

        if not devs:
            raise SystemExit("could not open any input device to sniff.")

        print("\n▶ Turn the knob (rotate it a bit) to identify it…", flush=True)
        print("  (quit in %gs or press Ctrl-C)\n" % int(timeout), flush=True)

        start = time.monotonic()
        while time.monotonic() - start < timeout:
            # Select on descriptors; returns readable ones.
            r, _, _ = select.select(devs, [], [], 1.0)
            for dev in r:
                for event in dev.read():
                    if event.type == E.EV_KEY and event.code in SCROLL_KEYS:
                        print(
                            f"✓ detected knob: {dev.name}  ({dev.path})\n", flush=True
                        )
                        # Keep the found device open for the caller; remove it
                        # from the cleanup list so `finally` won't close it.
                        devs.remove(dev)
                        return dev
        print("no knob activity detected within the timeout.\n", flush=True)
        return None
    except KeyboardInterrupt:
        print("\nbye", flush=True)
        return None
    finally:
        for d in devs:
            d.close()


def pump(device: InputDevice, ui: UInput, flip: bool, pace: int = 1) -> None:
    """Translate knob volume-key events into wheel scroll events.

    ``pace`` is the number of wheel notches emitted per knob detent
    (default 1 = 1:1). At 2, one knob movement scrolls twice as far.

    NOTE: this only READS the device. We deliberately do NOT grab it —
    the knob's volume keys share a device node with the keyboard, so
    grabbing swallows typing. Reading is safe and never interferes.
    """
    for event in device.read_loop():
        # Only act on key events we know how to convert.
        if event.type != E.EV_KEY or event.code not in SCROLL_KEYS:
            continue

        # value: 1 = pressed (key down); 0 = released; 2 = auto-repeat.
        if event.value != 1:
            continue

        step = SCROLL_KEYS[event.code]
        if flip:
            step = -step

        # Emit the same two events a real wheel mouse produces (verified by
        # listen-scroll.py): REL_WHEEL (+-1) plus REL_WHEEL_HI_RES (+-120).
        # Writing only REL_WHEEL is ignored by some compositors.
        ui.write(E.EV_REL, E.REL_WHEEL, step * pace)
        ui.write(E.EV_REL, E.REL_WHEEL_HI_RES, step * 120 * pace)
        ui.syn()
        log.debug(
            "scroll pace=%d (%+d) from key code 0x%02x", pace, step * pace, event.code
        )


# ---------------------------------------------------------------------------
# Temporary MangoWM volume-key unbind --------------------------------------
# ---------------------------------------------------------------------------
# MangoWM has no runtime "unbind" IPC command, so to stop the knob from also
# changing volume we temporarily comment out the volume binds in the live
# keybinds.conf, reload MangoWM, and restore the file on exit. Nothing is
# committed: the repo file is only modified while the script runs and is
# always restored (even on Ctrl-C).

# Lines in keybinds.conf that bind the volume keys. We comment these out
# while the script runs and restore them on exit.
VOLUME_BIND_PATTERNS = (
    "XF86AudioRaiseVolume",
    "XF86AudioLowerVolume",
)


def find_keybinds_conf() -> str | None:
    """Locate the active MangoWM keybinds.conf.

    Checks the live ~/.dotfiles symlink first, then the repo copy.
    Returns the path or None if not found.
    """
    candidates = [
        os.path.expanduser("~/.dotfiles/mangowm/keybinds.conf"),
        "/home/rtm/GIT-REPOS/workstation/dotfiles/mangowm/keybinds.conf",
    ]
    for path in candidates:
        if os.path.isfile(path):
            return path
    return None


def _mmsg(*args: str) -> None:
    """Run `mmsg`, pointing it at the mango IPC socket.

    Under `sudo` the user's environment is stripped, so MANGO_INSTANCE_SIGNATURE
    is missing and mmsg fails. We set it ourselves by locating the socket:
    /run/user/<real-uid>/mango-<pid>.sock

    Note: os.getuid() returns 0 under sudo, so we resolve the real user's
    uid from the running mango process instead.
    """
    import subprocess

    if not os.environ.get("MANGO_INSTANCE_SIGNATURE"):
        try:
            # Find the mango process and its owner uid.
            procs = (
                subprocess.run(["pgrep", "-x", "mango"], capture_output=True, text=True)
                .stdout.strip()
                .splitlines()
            )
            if procs:
                pid = procs[0]
                # uid of the process that owns the socket
                uid = subprocess.run(
                    ["stat", "-c", "%U", f"/proc/{pid}"],
                    capture_output=True,
                    text=True,
                ).stdout.strip()
                # stat %U gives a name; map it to a numeric uid via pwd
                import pwd

                try:
                    uid_num = pwd.getpwnam(uid).pw_uid
                except KeyError:
                    uid_num = os.getuid()
                sock = f"/run/user/{uid_num}/mango-{pid}.sock"
                if os.path.exists(sock):
                    os.environ["MANGO_INSTANCE_SIGNATURE"] = sock
                else:
                    log.warning("mango socket not found: %s", sock)
        except OSError as exc:
            log.warning("could not find mango socket: %s", exc)

    cmd = ["mmsg"] + list(args)
    subprocess.run(cmd)


def temporarily_unbind_volume() -> tuple[str | None, list[str] | None]:
    """Comment out the volume binds in keybinds.conf and reload MangoWM.

    Returns (path, original_lines) so the caller can restore on exit.
    Returns (None, None) if the config can't be found or has no volume binds.
    """
    path = find_keybinds_conf()
    if path is None:
        log.warning("could not find keybinds.conf; volume keys may still change volume")
        return None, None

    try:
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
    except OSError as exc:
        log.warning(
            "could not read %s (%s); volume keys may still change volume", path, exc
        )
        return None, None

    changed = False
    new_lines = list(lines)
    for i, line in enumerate(new_lines):
        stripped = line.strip()
        # Only touch active (non-commented) bind lines for volume keys.
        if stripped.startswith("#"):
            continue
        if any(p in stripped for p in VOLUME_BIND_PATTERNS):
            new_lines[i] = "# sound-scroller temp: " + line
            changed = True

    if not changed:
        return None, None

    try:
        with open(path, "w", encoding="utf-8") as fh:
            fh.writelines(new_lines)
    except OSError as exc:
        log.warning(
            "could not write %s (%s); volume keys may still change volume", path, exc
        )
        return None, None

    # Reload MangoWM so the change takes effect.
    _mmsg("dispatch", "reload_config")
    log.info("temporarily unbound volume keys in %s", path)
    return path, lines


def restore_volume_binds(path: str | None, original: list[str] | None) -> None:
    """Restore the original keybinds.conf and reload MangoWM."""
    if path is None or original is None:
        return
    try:
        with open(path, "w", encoding="utf-8") as fh:
            fh.writelines(original)
        _mmsg("dispatch", "reload_config")
        log.info("restored volume keys in %s", path)
    except OSError as exc:
        log.warning("could not restore %s (%s); please restore it manually", path, exc)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="sound-scroller",
        description="Turn a volume knob into a page scroller (wheel input).",
        epilog="Example:\n  sudo python3 sound-scroller.py --name knob --verbose\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--device", help="Exact input path, e.g. /dev/input/event7.")
    parser.add_argument(
        "--name",
        default="*",
        help=(
            "Auto-select the first device whose name contains this substring "
            "(default: none -> show the interactive selection menu)."
        ),
    )
    parser.add_argument(
        "--flip", action="store_true", help="Invert wheel direction if backwards."
    )
    parser.add_argument(
        "--pace",
        type=int,
        default=PACE,
        help=(
            "How many scroll notches each knob detent equals "
            f"(default: {PACE}, from PACE in the script). "
            "Use 2 for double scroll speed, 3 for triple, etc."
        ),
    )
    parser.add_argument(
        "--menu",
        action="store_true",
        help="Show the numbered selection menu instead of auto-sniffing.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=30.0,
        help="Seconds to wait for knob activity when sniffing (default: 30).",
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose logging.")
    args = parser.parse_args(argv)

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    if os.geteuid() != 0:
        log.warning(
            "Reading /dev/input and creating uinput usually needs root; "
            "use sudo if you hit 'Permission denied'."
        )

    knob = select_device(args)
    if knob is None:
        raise SystemExit(
            "Could not find the knob. Give --device or a matching --name.\n"
            "Candidates:  ls /dev/input/by-id/\n"
            "Inspect:     sudo evtest"
        )

    ui = create_virtual_mouse("sound-scroller virtual mouse")
    log.info("knob : %s  (%s)", knob.name, knob.path)
    log.info("mode : volume-keys -> wheel scroll (flip=%s)", args.flip)

    # Temporarily unbind the volume keys in MangoWM so the knob doesn't also
    # change volume while we use it for scrolling. Restored on exit.
    cfg_path, cfg_original = temporarily_unbind_volume()

    # We deliberately do NOT grab the device. The knob's volume keys share a
    # device node with the user's keyboard, so grabbing swallows typing and
    # locks input (we tried it — bad). We only READ events, which lets us
    # scroll without interfering with typing or anything else.

    try:
        log.info("listening; press Ctrl-C to quit (pace=%d)", args.pace)
        pump(knob, ui, args.flip, args.pace)
    except KeyboardInterrupt:
        log.info("bye")
    finally:
        restore_volume_binds(cfg_path, cfg_original)
        knob.close()
        ui.close()

    return 0


if __name__ == "__main__":
    sys.exit(main())
