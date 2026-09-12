#!/usr/bin/env python3
# Battery reader for the Sony INZONE Buds USB dongle (VID 054c / PID 0ec2).
#
# The dongle exposes no standard HID power-supply usage page, so upower and ALSA
# see nothing (its ALSA card only carries PCM/Headset switches). Its vendor HID
# interface also refuses to be polled: HIDIOCGFEATURE on reports 0xA0/0xA1 returns
# all zeros, and Sony's MDR battery query (0x22 with inquired-type 0x09/0x0A/0x00,
# framed 3e ... 3c) draws no reply on any output report or transport variant.
# The dongle only ever *pushes* unsolicited input reports on report ID 0x02, and
# does so roughly every 6-7 minutes.
#
# That is why this runs as a daemon: the value cannot be fetched on demand, only
# caught as it arrives and cached. Report layout, derived from 9 consecutive
# samples logged over ~50 minutes of real use:
#
#   idx:  0   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
#         12 04 ff 0f 00 96 c3 14 04 a0 01 00 00 ff 00 26 ff 64 9a
#         ^len        ^--------- payload ---------^    ^bat    ^cksum
#
#   idx 0     frame length excluding itself (frame spans idx 0..len)
#   idx 3     payload length (= idx0 - 3); payload spans idx 4..len
#   idx 7,8   message type. 14 04 = battery; 12 01 = per-bud dock state, whose
#             idx 12 (left) and idx 13 (right) are 1 when that bud is out of the
#             case and 0 when docked
#   idx 13    LEFT bud percentage, or 0xff when that bud is not reporting
#   idx 15    RIGHT bud percentage, or 0xff when that bud is not reporting
#   idx 17    case percentage (100 in every sample so far)
#
# A slot reads 0xff both before a bud has ever reported and once it falls asleep
# in the case, so 0xff means "no reading", never "empty". A docked bud keeps
# reporting its last level for a few minutes before dropping to 0xff.
#   idx 14,16 always 00 and ff respectively; role unknown
#   idx len   checksum: sum(data[4:len]) & 0xFF
#
# The checksum rule verifies on both observed message types, including the shorter
# "12 01" one where it lands at idx 14 instead of idx 18. That is what confirms
# the framing, rather than a coincidence fitted to a single message shape.
#
# Unlike protoarc-battery.py (whose feature report turned out to be a static
# cached value), this reading is demonstrably live: samples fell 46 -> 23
# monotonically, one point per ~6.4 min, extrapolating to ~11 h of runtime, which
# matches the ~12 h these buds are rated for.
#
# The left/right assignment of idx 13 and idx 15 was pinned down by a controlled
# test, not guessed. With the right bud worn and the left in the case, idx 13 read
# 0xff while idx 15 tracked the discharge 46 -> 23. Docking the right bud and
# removing the left then made idx 13 appear at 100 - a full bud leaving the case -
# while idx 15 held the worn bud's ~29 and dropped to 0xff once that bud fell
# asleep docked. The 12 01 message flipped idx 12/idx 13 to match at every step,
# reading 1/0 with only the left bud out and 1/1 with both out.
#
# Absolute values have NOT been cross-checked against Sony's own INZONE Hub, and
# idx 17 is assumed to be the case only because it stayed at 100 while both buds
# moved independently.
#
# Requires read access to /dev/hidraw* for this device, granted by
# /etc/udev/rules.d/99-inzone-buds.rules.
#
# Usage:
#   inzone-battery.py --daemon   listen forever, maintain the cache
#   inzone-battery.py            print "L 100%  R 29%", exit 1 if unknown/stale
#   inzone-battery.py --percent  print just the worst reporting bud, e.g. "29"
#   inzone-battery.py --json     print left/right/case separately, plus age
import argparse
import errno
import glob
import json
import os
import select
import sys
import time

VID = "054C"
PID = "0EC2"

REPORT_ID = 0x02
MSG_BATTERY = (0x14, 0x04)
IDX_TYPE = 7
IDX_LEFT = 13
IDX_RIGHT = 15
IDX_CASE = 17

# A slot reads 0xff when that bud is not reporting - either it has never woken
# since the dongle connected, or it is asleep in the case. Not the same as empty.
UNKNOWN = 0xFF

# Reports arrive every ~6.6 min while in use, so a value older than this means the
# buds are off or out of range rather than simply idle between reports.
DEFAULT_MAX_AGE = 1800

RETRY_DELAY = 5.0


def cache_path():
    base = os.environ.get("XDG_RUNTIME_DIR")
    if not base or not os.path.isdir(base):
        base = "/tmp/mangowm-%d" % os.getuid()
        os.makedirs(base, exist_ok=True)
    return os.path.join(base, "inzone-battery.json")


def find_device():
    for uevent_path in glob.glob("/sys/class/hidraw/hidraw*/device/uevent"):
        try:
            content = open(uevent_path).read().upper()
        except OSError:
            continue
        if VID in content and PID in content:
            return "/dev/" + uevent_path.split("/")[4]
    return None


def _slot(value):
    """A battery slot: 0-100, or None when absent (0xff) or out of range."""
    if value == UNKNOWN or value > 100:
        return None
    return value


def parse_report(data):
    """Return {"left", "right", "case"} for a battery report, else None.

    `data` is a raw hidraw read, i.e. the report ID followed by the frame.
    Slots are None when that bud has not reported. Returns None (rather than a
    dict of Nones) if no slot at all could be read, so the caller never caches
    an empty reading.
    """
    if len(data) < 2 or data[0] != REPORT_ID:
        return None
    body = data[1:]

    length = body[0]
    if length <= IDX_CASE or length >= len(body):
        return None
    if body[3] != length - 3:
        return None
    if (sum(body[4:length]) & 0xFF) != body[length]:
        return None
    if (body[IDX_TYPE], body[IDX_TYPE + 1]) != MSG_BATTERY:
        return None

    slots = {
        "left": _slot(body[IDX_LEFT]),
        "right": _slot(body[IDX_RIGHT]),
        "case": _slot(body[IDX_CASE]),
    }
    if slots["left"] is None and slots["right"] is None:
        return None
    return slots


def write_cache(path, entry):
    tmp = path + ".tmp"
    with open(tmp, "w") as handle:
        json.dump(entry, handle)
    os.replace(tmp, path)


def drop_cache(path):
    try:
        os.unlink(path)
    except OSError:
        pass


def format_slots(entry):
    """Render both buds, e.g. "L 100%  R 29%". A bud that is not reporting
    shows as "--" rather than being omitted, so the two columns stay aligned."""
    def one(key):
        value = entry.get(key)
        return "--" if value is None else "%d%%" % value

    return "L %s  R %s" % (one("left"), one("right"))


def run_daemon(path):
    fd = None
    warned_eacces = False

    while True:
        if fd is None:
            device = find_device()
            if device is None:
                # Dongle unplugged - drop the cache so nothing stale is shown.
                drop_cache(path)
                time.sleep(RETRY_DELAY)
                continue
            try:
                fd = os.open(device, os.O_RDONLY | os.O_NONBLOCK)
                warned_eacces = False
            except OSError as exc:
                if exc.errno == errno.EACCES and not warned_eacces:
                    print(
                        "inzone-battery: no read access to %s - install "
                        "/etc/udev/rules.d/99-inzone-buds.rules" % device,
                        file=sys.stderr,
                    )
                    warned_eacces = True
                time.sleep(RETRY_DELAY)
                continue

        try:
            ready, _, _ = select.select([fd], [], [], RETRY_DELAY)
            data = os.read(fd, 128) if ready else b""
        except OSError:
            data = b""
            ready = True

        if ready and not data:
            # Device went away mid-read; reopen on the next pass.
            os.close(fd)
            fd = None
            continue
        if not data:
            continue

        slots = parse_report(data)
        if slots is None:
            continue
        entry = dict(slots)
        # "percent" is the worst bud that is actually reporting - that is what a
        # bar should badge and warn on, since either bud going flat ends playback.
        entry["percent"] = min(v for v in (slots["left"], slots["right"]) if v is not None)
        entry["updated"] = int(time.time())
        write_cache(path, entry)


def main():
    parser = argparse.ArgumentParser(
        description="Read the Sony INZONE Buds battery level via its USB dongle."
    )
    parser.add_argument(
        "--daemon",
        action="store_true",
        help="listen for dongle reports and keep the cache up to date",
    )
    parser.add_argument(
        "--percent",
        action="store_true",
        help="print only the worst reporting bud, for a single-value progress bar",
    )
    parser.add_argument(
        "--json", action="store_true", help="print the full cache entry as JSON"
    )
    parser.add_argument(
        "--max-age",
        type=int,
        default=DEFAULT_MAX_AGE,
        metavar="SECONDS",
        help="treat a cached value older than this as unknown (0 disables, default %(default)s)",
    )
    args = parser.parse_args()
    path = cache_path()

    if args.daemon:
        try:
            run_daemon(path)
        except KeyboardInterrupt:
            pass
        return 0

    try:
        with open(path) as handle:
            entry = json.load(handle)
    except (OSError, ValueError):
        return 1

    # Reject a cache entry written by an older version that only stored a single
    # aggregate value, rather than silently reporting both buds as unknown.
    if "left" not in entry and "right" not in entry:
        return 1

    entry["age"] = int(time.time()) - int(entry.get("updated", 0))
    if args.max_age > 0 and entry["age"] > args.max_age:
        return 1

    if args.json:
        print(json.dumps(entry))
    elif args.percent:
        print(entry["percent"])
    else:
        print(format_slots(entry))
    return 0


if __name__ == "__main__":
    sys.exit(main())
