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
import threading
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


def run_json(cmd, timeout=5):
    """Run command and return JSON output with timeout"""
    try:
        out = subprocess.check_output(cmd, text=True, timeout=timeout)
        return json.loads(out)
    except subprocess.TimeoutExpired:
        raise Exception(f"Command timed out: {' '.join(cmd)}")
    except subprocess.CalledProcessError as e:
        raise Exception(f"Command failed: {' '.join(cmd)} - {e}")
    except json.JSONDecodeError as e:
        raise Exception(f"Invalid JSON from command: {' '.join(cmd)} - {e}")


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
                    # Capabilities might not be available or accessible
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

        # Sort by score (highest first) and return the best match
        if mouse_candidates:
            mouse_candidates.sort(key=lambda x: x[0], reverse=True)
            best_score, best_path, best_name = mouse_candidates[0]
            logging.info(
                f"Found {len(mouse_candidates)} mouse candidates, best: {best_name} (score: {best_score})")
            return best_path, best_name

    except Exception as e:
        logging.warning(f"Error scanning devices: {e}")

    return None, None


def cursor_xy():
    """Get cursor position with error handling"""
    try:
        j = run_json(["hyprctl", "cursorpos", "-j"])
        return int(j["x"]), int(j["y"])
    except Exception as e:
        logging.error(f"Failed to get cursor position: {e}")
        raise


class MonitorMap:
    def __init__(self):
        self._last = 0.0
        self._cache = []

    def refresh(self, max_age=5.0):
        now = time.monotonic()
        if now - self._last > max_age or not self._cache:
            try:
                j = run_json(["hyprctl", "monitors", "-j"])
                self._cache = [(int(m["x"]), int(m["y"]), int(
                    m["width"]), int(m["height"])) for m in j]
                self._last = now
            except Exception as e:
                logging.error(f"Failed to refresh monitor map: {e}")
                # Keep using old cache if available

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
    ap.add_argument("--device", default=None,
                    help="Input device path (auto-detect if not specified)")
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

    # Right-click menu command
    ap.add_argument("--right-click-cmd", default="jgmenu --at-pointer",
                    help="command to run on right-click in edge areas (default: jgmenu --at-pointer)")
    ap.add_argument("--right-click-debounce-ms", type=int, default=300,
                    help="right-click debounce time (ms)")

    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    # Setup logging
    logger = setup_logging(args.debug)

    # Auto-detect device if not specified
    device_path = args.device
    if not device_path:
        logger.info("Auto-detecting mouse device...")
        device_path, device_name = find_mouse_device()
        if device_path:
            logger.info(f"Found mouse device: {device_path} ({device_name})")
        else:
            logger.error(
                "No suitable mouse device found. Please specify --device manually.")
            sys.exit(1)
    else:
        logger.info(f"Using specified device: {device_path}")

    # Open devices with retry logic and fallback
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
                logger.warning(
                    f"Attempt {attempt + 1}/{max_retries} failed to open {device_path}: {err}")
                if attempt == max_retries - 1:
                    logger.warning(
                        f"Failed to open {device_path} after all retries")
                    break
                await asyncio.sleep(1)

        if dev is None:
            fallback_attempts += 1
            if fallback_attempts < max_fallback_attempts:
                logger.info(
                    f"Trying to find alternative mouse device (attempt {fallback_attempts}/{max_fallback_attempts})...")
                device_path, device_name = find_mouse_device()
                if device_path:
                    logger.info(
                        f"Trying alternative device: {device_path} ({device_name})")
                else:
                    logger.error("No alternative mouse devices found")
                    break
            else:
                logger.error(
                    "Failed to open any mouse device after all fallback attempts")
                logger.error(
                    "Fix permissions for /dev/input/event*, or run once with sudo, then add user to 'input' group.")
                sys.exit(1)

    try:
        ui = make_uinput(args.use_shift_for_plus)
        logger.info("Successfully created uinput device")
    except Exception as err:
        logger.error(f"Failed to open /dev/uinput: {err}")
        logger.error(
            "Ensure /dev/uinput is group 'input' and you are in that group, or create a udev rule.")
        sys.exit(1)

    monmap = MonitorMap()

    # Separate clocks for debouncing
    last_vert_ts = 0.0
    last_horiz_ts = 0.0
    last_right_click_ts = 0.0
    debounce_vert = args.debounce_ms / 1000.0
    debounce_horiz = args.horiz_debounce_ms / 1000.0
    debounce_right_click = args.right_click_debounce_ms / 1000.0

    REL_WHEEL_HI_RES = getattr(EC, "REL_WHEEL_HI_RES", 11)
    REL_HWHEEL_HI_RES = getattr(EC, "REL_HWHEEL_HI_RES", 12)

    logger.info(f"Starting mouse actions with device={device_path} Tmargin={args.margin_top} Bmargin={args.margin_bottom} "
                f"vert_debounce={debounce_vert}s horiz_debounce={debounce_horiz}s "
                f"top_enabled={args.enable_top} bottom_enabled={args.enable_bottom}")

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
                logger.debug("horiz debounced")
                continue
            last_horiz_ts = now

            try:
                if v < 0:
                    seq = [EC.KEY_LEFTCTRL]
                    if args.use_shift_for_plus:
                        seq.append(EC.KEY_LEFTSHIFT)
                    # '+' with shift on many layouts
                    seq.append(EC.KEY_EQUAL)
                    press_combo(ui, seq)
                    logger.debug("hwheel left  -> Ctrl++")
                elif v > 0:
                    press_combo(ui, [EC.KEY_LEFTCTRL, EC.KEY_MINUS])
                    logger.debug("hwheel right -> Ctrl+-")
            except Exception as e:
                logger.error(f"Error processing horizontal wheel: {e}")
            continue

        # ---------- Right-click in edge areas => jgmenu_run ----------
        if ev.type == EC.EV_KEY and ev.code == EC.BTN_RIGHT and ev.value == 1:
            now = time.monotonic()
            if now - last_right_click_ts < debounce_right_click:
                logger.debug("right-click debounced")
                continue
            last_right_click_ts = now

            try:
                x, y = cursor_xy()
            except Exception as err:
                logger.warning(f"hyprctl failed: {err}")
                continue

            which = monmap.edge_for(
                x, y, args.margin_top, args.margin_bottom, args.enable_top, args.enable_bottom)
            logger.debug(f"right-click at x={x} y={y} edge={which}")
            if which:
                logger.debug(f"run: {args.right_click_cmd}")
                try:
                    lockfile_path = os.path.expanduser("~/.jgmenu-lockfile")

                    # Always remove lockfile before execution
                    if os.path.exists(lockfile_path):
                        try:
                            os.remove(lockfile_path)
                            logger.debug(
                                "Removed jgmenu lockfile before execution")
                        except Exception as e:
                            logger.warning(
                                f"Could not remove lockfile before execution: {e}")

                    # Run the command with proper process handling
                    process = subprocess.Popen(
                        ["bash", "-lc", args.right_click_cmd],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        start_new_session=True
                    )

                    # Clean up lockfile after process exits (non-blocking)
                    def cleanup_lockfile_after_exit(proc, lockfile):
                        try:
                            proc.wait(timeout=30)  # Wait up to 30 seconds
                        except subprocess.TimeoutExpired:
                            pass
                        # Always remove lockfile after process exits
                        if os.path.exists(lockfile):
                            try:
                                # Small delay to let jgmenu clean up itself
                                time.sleep(0.1)
                                if os.path.exists(lockfile):
                                    os.remove(lockfile)
                                    logger.debug(
                                        "Removed jgmenu lockfile after execution")
                            except Exception as e:
                                logger.debug(
                                    f"Could not remove lockfile after execution: {e}")

                    # Start cleanup in background
                    cleanup_thread = threading.Thread(
                        target=cleanup_lockfile_after_exit,
                        args=(process, lockfile_path),
                        daemon=True
                    )
                    cleanup_thread.start()
                except Exception as e:
                    logger.error(
                        f"Failed to execute command: {args.right_click_cmd} - {e}")
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
            logger.debug("vert debounced")
            continue
        last_vert_ts = now

        try:
            x, y = cursor_xy()
        except Exception as err:
            logger.warning(f"hyprctl failed: {err}")
            continue

        which = monmap.edge_for(
            x, y, args.margin_top, args.margin_bottom, args.enable_top, args.enable_bottom)
        logger.debug(f"vert wheel={v} at x={x} y={y} edge={which}")
        if not which:
            continue

        cmd = (args.top_cmd_up if v < 0 else args.top_cmd_down) if which == "top" \
            else (args.bottom_cmd_up if v < 0 else args.bottom_cmd_down)

        logger.debug(f"run: {cmd}")
        try:
            subprocess.Popen(["bash", "-lc", cmd])
        except Exception as e:
            logger.error(f"Failed to execute command: {cmd} - {e}")


def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    print(f"\nReceived signal {signum}, shutting down...")
    sys.exit(0)


if __name__ == "__main__":
    # Setup signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nShutdown requested by user")
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)
