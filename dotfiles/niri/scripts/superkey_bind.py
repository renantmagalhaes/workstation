#!/usr/bin/env python3
import asyncio
import evdev
from evdev import ecodes as EC
import subprocess
import os
import sys
import logging
import argparse

# Global state
active_supers = set()
compromised = False

def setup_logging(debug=False):
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler(sys.stderr)]
    )
    return logging.getLogger(__name__)

def is_keyboard(device):
    try:
        caps = device.capabilities()
        if EC.EV_KEY in caps:
            keys = caps[EC.EV_KEY]
            # Keyboards typically have KEY_A and KEY_ENTER
            return EC.KEY_A in keys and EC.KEY_ENTER in keys
    except Exception:
        pass
    return False

def get_active_monitor(logger):
    try:
        out = subprocess.check_output(["mmsg", "-g", "-o"], text=True)
        for line in out.splitlines():
            parts = line.strip().split()
            if len(parts) >= 3 and parts[1] == "selmon" and parts[2] == "1":
                return parts[0]
    except Exception as e:
        logger.error(f"Failed to get active monitor: {e}")
    return None

async def monitor_keyboard(device_path, device_name, logger):
    global compromised
    logger.info(f"Monitoring keyboard: {device_path} ({device_name})")
    try:
        device = evdev.InputDevice(device_path)
        async for event in device.async_read_loop():
            if event.type == EC.EV_KEY:
                # 125 is LEFTMETA (Super_L)
                is_super = (event.code == EC.KEY_LEFTMETA)
                
                if event.value == 1:  # Pressed
                    if is_super:
                        active_supers.add((device_path, event.code))
                        # Check if any other key was already held down
                        try:
                            active = device.active_keys()
                            other_keys = [k for k in active if k != event.code]
                            if other_keys:
                                compromised = True
                                logger.debug(f"Super pressed on {device_name}, but other keys are down: {other_keys}. Compromised.")
                            else:
                                compromised = False
                                logger.debug(f"Super pressed on {device_name}. State is clean.")
                        except Exception:
                            compromised = False
                    else:
                        if active_supers:
                            compromised = True
                            logger.debug(f"Other key {event.code} pressed while Super is held. Compromised.")
                
                elif event.value == 0:  # Released
                    if is_super:
                        key_state = (device_path, event.code)
                        if key_state in active_supers:
                            if not compromised:
                                logger.info("Super key released alone! Spawning spotlight.")
                                try:
                                    active_mon = get_active_monitor(logger)
                                    logger.info(f"Active monitor detected: {active_mon}")
                                    subprocess.Popen([os.path.expanduser("~/.QS-Launcher/spotlight"), active_mon or ""])
                                except Exception as e:
                                    logger.error(f"Failed to launch spotlight: {e}")
                            active_supers.discard(key_state)
                            if not active_supers:
                                compromised = False
                    else:
                        # Key released
                        pass
    except OSError:
        logger.warning(f"Keyboard disconnected: {device_path} ({device_name})")
    except Exception as e:
        logger.error(f"Error in monitor loop for {device_path}: {e}")

async def rescan_loop(logger):
    monitored_devices = {}  # path -> Task
    
    while True:
        try:
            current_devices = evdev.list_devices()
            
            # Start monitoring new devices
            for path in current_devices:
                if path not in monitored_devices:
                    try:
                        device = evdev.InputDevice(path)
                        if is_keyboard(device):
                            task = asyncio.create_task(monitor_keyboard(path, device.name, logger))
                            monitored_devices[path] = task
                    except Exception:
                        pass
            
            # Clean up finished/stale tasks
            to_remove = []
            for path, task in monitored_devices.items():
                if task.done():
                    to_remove.append(path)
            for path in to_remove:
                del monitored_devices[path]
                
        except Exception as e:
            logger.error(f"Error in rescan loop: {e}")
            
        await asyncio.sleep(3)

def main():
    ap = argparse.ArgumentParser(description="Solo Super key release daemon")
    ap.add_argument("--debug", action="store_true", help="Enable debug logging")
    args = ap.parse_args()
    
    logger = setup_logging(args.debug)
    logger.info("Starting superkey_bind daemon...")
    
    try:
        asyncio.run(rescan_loop(logger))
    except KeyboardInterrupt:
        logger.info("Shutting down...")
    except Exception as e:
        logger.critical(f"Unhandled error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
