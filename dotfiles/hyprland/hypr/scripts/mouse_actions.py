#!/usr/bin/env python3
# To fix "/dev/uinput" permissions:
# sudo rm /etc/udev/rules.d/40-uinput.rules /etc/udev/rules.d/90-uinput.rules
# echo 'KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess", RUN+="/usr/bin/setfacl -m g:input:rw /dev/$name"' | sudo tee /etc/udev/rules.d/99-uinput.rules
# sudo udevadm control --reload-rules && sudo udevadm trigger
# sudo setfacl -m g:input:rw /dev/uinput
import asyncio
import argparse
import os
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

def find_mouse_device():
    """Find the best mouse device automatically"""
    try:
        devices = list_devices()
        mouse_candidates = []

        for device_path in devices:
            try:
                device = InputDevice(device_path)
                device_name = device.name.lower()

                # Check if device has mouse capabilities
                has_wheel = False
                has_rel = False
                try:
                    caps = device.capabilities
                    if isinstance(caps, dict) and EC.EV_REL in caps:
                        rel_caps = caps[EC.EV_REL]
                        has_wheel = EC.REL_WHEEL in rel_caps or EC.REL_HWHEEL in rel_caps
                        has_rel = True
                except (AttributeError, TypeError):
                    pass

                # Score devices based on name and capabilities
                score = 0
                if "mouse" in device_name:
                    score += 10
                if "logitech" in device_name:
                    score += 5
                if has_wheel:
                    score += 3
                if has_rel:
                    score += 1

                if score > 0:
                    mouse_candidates.append((score, device_path, device.name))

            except (OSError, PermissionError):
                continue
            except Exception as e:
                logging.debug(f"Error checking device {device_path}: {e}")
                continue

        if mouse_candidates:
            mouse_candidates.sort(key=lambda x: x[0], reverse=True)
            best_score, best_path, best_name = mouse_candidates[0]
            logging.info(f"Found {len(mouse_candidates)} mouse candidates, best: {best_name} (score: {best_score})")
            return best_path, best_name

    except Exception as e:
        logging.warning(f"Error scanning devices: {e}")

    return None, None

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

    device_path = args.device
    if not device_path:
        logger.info("Auto-detecting mouse device...")
        device_path, device_name = find_mouse_device()
        if device_path:
            logger.info(f"Found mouse device: {device_path} ({device_name})")
        else:
            logger.error("No suitable mouse device found. Please specify --device manually.")
            sys.exit(1)
    else:
        logger.info(f"Using specified device: {device_path}")

    dev = None
    max_retries = 3
    fallback_attempts = 0
    max_fallback_attempts = 3

    while dev is None and fallback_attempts < max_fallback_attempts:
        for attempt in range(max_retries):
            try:
                dev = InputDevice(device_path)
                logger.info(f"Successfully opened device: {device_path}")
                break
            except Exception as err:
                logger.warning(f"Attempt {attempt + 1}/{max_retries} failed to open {device_path}: {err}")
                if attempt == max_retries - 1:
                    logger.warning(f"Failed to open {device_path} after all retries")
                    break
                await asyncio.sleep(1)

        if dev is None:
            fallback_attempts += 1
            if fallback_attempts < max_fallback_attempts:
                logger.info(f"Trying alternative device...")
                device_path, device_name = find_mouse_device()
            else:
                logger.error("Failed to open any mouse device.")
                sys.exit(1)

    try:
        ui = make_uinput(args.use_shift_for_plus)
        logger.info("Successfully created uinput device")
    except Exception as err:
        logger.error(f"Failed to open /dev/uinput: {err}")
        sys.exit(1)

    last_horiz_ts = 0.0
    debounce_horiz = args.horiz_debounce_ms / 1000.0
    REL_HWHEEL_HI_RES = getattr(EC, "REL_HWHEEL_HI_RES", 12)

    logger.info(f"Starting global horizontal wheel zoom daemon with device={device_path}")

    async for ev in dev.async_read_loop():
        if ev.type == EC.EV_REL and ev.code in (EC.REL_HWHEEL, REL_HWHEEL_HI_RES):
            v = ev.value
            if ev.code == REL_HWHEEL_HI_RES:
                v = -1 if v < 0 else (1 if v > 0 else 0)
            if args.invert_hwheel:
                v = -v

            now = time.monotonic()
            if now - last_horiz_ts < debounce_horiz:
                continue
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
