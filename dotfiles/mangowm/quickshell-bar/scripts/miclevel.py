#!/usr/bin/python3
"""Stream the default audio source's level as a 0..1 value, one per line.

PipeWire exposes volume and mute through Quickshell, but no peak/level, so the
only way to show real microphone activity is to open a capture stream and
measure it. parec is used rather than pw-cat because a pulse client with no
explicit device follows the default source when it changes, which keeps this
script free of any device-tracking logic.

The bar only runs this while the source is unmuted, so muting genuinely closes
the capture instead of just zeroing the display.
"""

import array
import atexit
import ctypes
import math
import os
import signal
import subprocess
import sys
import time

RATE = 8000  # plenty for a level meter, and keeps the stream cheap
BLOCK = 400  # samples -> 50ms, i.e. 20 updates per second
SAMPLE_BYTES = 2

# Mapped in dB rather than linear amplitude: speech sits very low on a linear
# scale, so a linear bar would barely leave the floor at normal talking volume.
DB_FLOOR = -45.0
DB_CEIL = -5.0
DB_GATE = -50.0  # below this the bar reads as silent rather than as noise

DECAY = 0.80  # instant attack, eased release, so the bar is readable

# PR_SET_PDEATHSIG ensures the Linux kernel delivers SIGKILL to the child parec
# process if this parent Python process dies for ANY reason (SIGTERM, SIGKILL, crash, etc.).
PR_SET_PDEATHSIG = 1
try:
    _libc = ctypes.CDLL("libc.so.6")
except Exception:
    _libc = None


def _set_pdeathsig():
    if _libc is not None:
        try:
            _libc.prctl(PR_SET_PDEATHSIG, signal.SIGKILL)
        except Exception:
            pass


_current_proc = None


def cleanup():
    global _current_proc
    if _current_proc is not None:
        try:
            _current_proc.terminate()
            _current_proc.wait(timeout=0.1)
        except Exception:
            try:
                _current_proc.kill()
            except Exception:
                pass
        _current_proc = None


def _signal_handler(signum, frame):
    cleanup()
    sys.exit(0)


atexit.register(cleanup)
signal.signal(signal.SIGTERM, _signal_handler)
signal.signal(signal.SIGINT, _signal_handler)
signal.signal(signal.SIGHUP, _signal_handler)


def stream():
    global _current_proc

    proc = subprocess.Popen(
        [
            "parec",
            "--format=s16le",
            f"--rate={RATE}",
            "--channels=1",
            "--raw",
            "--latency-msec=50",
            "--stream-name=quickshell-bar meter",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        preexec_fn=_set_pdeathsig,
    )
    _current_proc = proc

    want = BLOCK * SAMPLE_BYTES
    level = 0.0

    try:
        while True:
            data = proc.stdout.read(want)
            if not data or len(data) < want:
                break

            samples = array.array("h", data)
            peak = max(abs(min(samples)), abs(max(samples))) / 32768.0

            if peak <= 0:
                db = DB_GATE
            else:
                db = 20.0 * math.log10(peak)

            if db <= DB_GATE:
                target = 0.0
            else:
                target = (db - DB_FLOOR) / (DB_CEIL - DB_FLOOR)
                target = max(0.0, min(1.0, target))

            level = target if target > level else level * DECAY

            print(f"{level:.3f}", flush=True)
    finally:
        cleanup()


def main():
    while True:
        try:
            stream()
        except BrokenPipeError:
            # Output pipe closed by Quickshell: terminate immediately.
            break
        except Exception:
            pass

        # The source can disappear mid-capture (device unplugged, profile
        # switch). Report silence and retry rather than exiting, so the meter
        # comes back on its own.
        try:
            print("0.000", flush=True)
        except BrokenPipeError:
            break

        time.sleep(1)


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        pass
    finally:
        cleanup()
        sys.exit(0)
