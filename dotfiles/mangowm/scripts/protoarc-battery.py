#!/usr/bin/env python3
# NOT CURRENTLY USED - not wired into mouse-battery.sh or battery-warning.sh.
# Logged samples over ~2 days of real use showed the entire feature report, not just
# byte offset 3, is bit-for-bit static - the receiver is echoing a cached value, not a
# live battery reading. The "100" this returns is not trustworthy. Kept for reference
# in case the real report/offset gets found later (e.g. via a USB capture of the
# vendor's own app, if one exists).
#
# Battery query for the ProtoArc EM01 NL trackball (rebranded "Compx 2.4G Receiver",
# USB VID 25a7 / PID fa61). It has no standard HID power-supply usage page, so it's
# invisible to upower/solaar. Its report descriptor exposes a vendor-defined feature
# report (ID 6, usage page 0xFF02); byte offset 3 was assumed to be a battery
# percentage from a single freshly-charged reading, but that assumption is now known
# to be wrong (see above).
#
# Requires read/write access to /dev/hidraw* for this device, granted by
# /etc/udev/rules.d/99-protoarc-mouse.rules.
import fcntl
import glob
import os
import sys

VID = "25a7"
PID = "fa61"
REPORT_ID = 6
BATTERY_OFFSET = 3


def _ioc(direction, type_, nr, size):
    return (direction << 30) | (type_ << 8) | nr | (size << 16)


def get_feature_report(device_path, report_id, length=16):
    fd = os.open(device_path, os.O_RDWR)
    try:
        buf = bytearray(length)
        buf[0] = report_id
        req = _ioc(3, ord("H"), 0x07, length)  # HIDIOCGFEATURE(length)
        return fcntl.ioctl(fd, req, bytes(buf), True)
    finally:
        os.close(fd)


def find_battery():
    for uevent_path in glob.glob("/sys/class/hidraw/hidraw*/device/uevent"):
        try:
            content = open(uevent_path).read().lower()
        except OSError:
            continue
        if VID not in content or PID not in content:
            continue

        device = "/dev/" + uevent_path.split("/")[4]
        try:
            data = get_feature_report(device, REPORT_ID)
        except OSError:
            continue

        if len(data) <= BATTERY_OFFSET or data[0] != REPORT_ID:
            continue

        if os.environ.get("PROTOARC_DEBUG"):
            print(f"{device} report {REPORT_ID} raw={list(data)}", file=sys.stderr)

        value = data[BATTERY_OFFSET]
        if 0 <= value <= 100:
            return value

    return None


if __name__ == "__main__":
    battery = find_battery()
    if battery is None:
        sys.exit(1)
    print(battery)
