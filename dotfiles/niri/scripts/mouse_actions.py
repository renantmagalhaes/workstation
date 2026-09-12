#!/usr/bin/env python3
# To fix "/dev/uinput" permissions:
# sudo rm /etc/udev/rules.d/40-uinput.rules /etc/udev/rules.d/90-uinput.rules
# echo 'KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess", RUN+="/usr/bin/setfacl -m g:input:rw /dev/$name"' | sudo tee /etc/udev/rules.d/99-uinput.rules
# sudo udevadm control --reload-rules && sudo udevadm trigger
# sudo setfacl -m g:input:rw /dev/uinput
import asyncio
import argparse
import sys
import logging
import signal
import time
from evdev import InputDevice, UInput, ecodes as EC, list_devices

def setup_logging(debug=False):
    """Setup logging configuration"""
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stderr)
        ]
    )
    return logging.getLogger(__name__)

REL_HWHEEL_HI_RES = getattr(EC, "REL_HWHEEL_HI_RES", 12)

# Our own uinput device, skipped so we never read back what we inject.
UINPUT_NAME = "edge-virtual-kbd"

# How often to look for a newly plugged-in mouse.
RESCAN_INTERVAL_S = 5

def find_hwheel_devices():
    """Open every input device that reports a horizontal wheel.

    Scoring a single "best" mouse by name broke whenever the mouse was
    swapped: generic mice tie with each other, so the winner came down to
    device enumeration order. Reading all of them removes the guess, and
    the debounce below collapses duplicates when a composite device
    reports the same notch twice.
    """
    devices = []
    for device_path in list_devices():
        try:
            device = InputDevice(device_path)
        except (OSError, PermissionError):
            continue

        try:
            rel_caps = device.capabilities().get(EC.EV_REL, [])
        except (AttributeError, TypeError, OSError):
            device.close()
            continue

        has_hwheel = EC.REL_HWHEEL in rel_caps or REL_HWHEEL_HI_RES in rel_caps
        if has_hwheel and device.name != UINPUT_NAME:
            devices.append(device)
        else:
            device.close()

    return devices

def make_uinput(use_shift_for_plus=False):
    keys = {EC.KEY_LEFTCTRL, EC.KEY_MINUS, EC.KEY_EQUAL}
    if use_shift_for_plus:
        keys.add(EC.KEY_LEFTSHIFT)
    return UInput({EC.EV_KEY: list(keys)}, name=UINPUT_NAME, bustype=0x03)

def press_combo(ui, codes):
    for c in codes:
        ui.write(EC.EV_KEY, c, 1)
    ui.syn()
    for c in reversed(codes):
        ui.write(EC.EV_KEY, c, 0)
    ui.syn()

async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--device", default=None,
                    help="Input device path (auto-detect if not specified)")
    ap.add_argument("--horiz-debounce-ms", type=int, default=20,
                    help="horizontal wheel debounce for Ctrl± (ms)")
    ap.add_argument("--invert-hwheel", action="store_true",
                    help="swap left and right meanings")
    ap.add_argument("--use-shift-for-plus", action="store_true",
                    help="send Ctrl+Shift+= instead of Ctrl+= if your layout needs Shift for '+'")
    ap.add_argument("--debug", action="store_true")
    
    # Ignored arguments for backwards-compatibility
    ap.add_argument("--margin-top", type=int, default=12, help="Ignored")
    ap.add_argument("--margin-bottom", type=int, default=12, help="Ignored")
    ap.add_argument("--debounce-ms", type=int, default=80, help="Ignored")
    ap.add_argument("--top-cmd-up", default=None, help="Ignored")
    ap.add_argument("--top-cmd-down", default=None, help="Ignored")
    ap.add_argument("--bottom-cmd-up", default=None, help="Ignored")
    ap.add_argument("--bottom-cmd-down", default=None, help="Ignored")
    ap.add_argument("--top", dest="enable_top", action="store_true", default=True, help="Ignored")
    ap.add_argument("--no-top", dest="enable_top", action="store_false", help="Ignored")
    ap.add_argument("--bottom", dest="enable_bottom", action="store_true", default=True, help="Ignored")
    ap.add_argument("--no-bottom", dest="enable_bottom", action="store_false", help="Ignored")
    ap.add_argument("--right-click-cmd", default=None, help="Ignored")
    ap.add_argument("--right-click-debounce-ms", type=int, default=300, help="Ignored")

    args = ap.parse_args()
    logger = setup_logging(args.debug)

    if args.device:
        try:
            devices = [InputDevice(args.device)]
        except Exception as err:
            logger.error(f"Failed to open {args.device}: {err}")
            sys.exit(1)
        logger.info(f"Using specified device: {args.device}")
    else:
        logger.info("Scanning for devices with a horizontal wheel...")
        devices = find_hwheel_devices()
        if not devices:
            logger.error("No horizontal-wheel device found. Check /dev/input permissions.")
            sys.exit(1)
        for device in devices:
            logger.info(f"Watching {device.path} ({device.name})")

    try:
        ui = make_uinput(args.use_shift_for_plus)
        logger.info("Successfully created uinput device")
    except Exception as err:
        logger.error(f"Failed to open /dev/uinput: {err}")
        sys.exit(1)

    last_horiz_ts = 0.0
    debounce_horiz = args.horiz_debounce_ms / 1000.0

    def handle(ev):
        nonlocal last_horiz_ts

        if ev.type != EC.EV_REL or ev.code not in (EC.REL_HWHEEL, REL_HWHEEL_HI_RES):
            return

        v = ev.value
        if ev.code == REL_HWHEEL_HI_RES:
            v = -1 if v < 0 else (1 if v > 0 else 0)
        if args.invert_hwheel:
            v = -v

        now = time.monotonic()
        if now - last_horiz_ts < debounce_horiz:
            return
        last_horiz_ts = now

        try:
            if v < 0:
                seq = [EC.KEY_LEFTCTRL]
                if args.use_shift_for_plus:
                    seq.append(EC.KEY_LEFTSHIFT)
                seq.append(EC.KEY_EQUAL)
                press_combo(ui, seq)
                logger.debug("hwheel left  -> Ctrl++")
            elif v > 0:
                press_combo(ui, [EC.KEY_LEFTCTRL, EC.KEY_MINUS])
                logger.debug("hwheel right -> Ctrl+-")
        except Exception as e:
            logger.error(f"Error processing horizontal wheel: {e}")

    async def pump(device):
        """Feed one device's events to the handler until it goes away."""
        try:
            async for ev in device.async_read_loop():
                handle(ev)
        except OSError:
            logger.info(f"Device disconnected: {device.path} ({device.name})")
        except Exception as e:
            logger.error(f"Read loop failed for {device.path}: {e}")
        finally:
            try:
                device.close()
            except Exception:
                pass

    watched = {d.path: asyncio.create_task(pump(d)) for d in devices}
    logger.info(f"Starting horizontal wheel zoom daemon on {len(watched)} device(s)")

    # Rescan so a mouse plugged in later is picked up without a restart.
    while True:
        await asyncio.sleep(RESCAN_INTERVAL_S)

        for path, task in list(watched.items()):
            if task.done():
                del watched[path]

        if args.device:
            if not watched:
                logger.error(f"Specified device {args.device} is gone. Exiting.")
                sys.exit(1)
            continue

        for device in find_hwheel_devices():
            if device.path in watched:
                device.close()
                continue
            logger.info(f"Watching {device.path} ({device.name})")
            watched[device.path] = asyncio.create_task(pump(device))

        if not watched:
            logger.warning("No horizontal-wheel device present; waiting for one.")

def signal_handler(signum, frame):
    sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
    except Exception as e:
        sys.exit(1)
