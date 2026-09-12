pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Sony INZONE Buds battery, per bud.
//
// UPower never sees these (the dongle exposes no HID power-supply usage page),
// so this cannot go through Battery.qml. The dongle also cannot be polled at
// all - it only pushes a report every few minutes - so inzone-battery.py
// --daemon caches the last reading and this just re-reads that cache.
//
// Polling a cache file is therefore cheap and never blocks on the device. The
// reader exits non-zero when nothing is cached yet or the cached value has aged
// out, which is what clears `present` and hides the chip.
Singleton {
    id: root

    // -1 means "not reporting": a bud asleep in the case, or one that has not
    // woken since the dongle connected. Never confuse it with an empty bud.
    property int left: -1
    property int right: -1
    property int caseLevel: -1
    property bool present: false

    readonly property int lowThreshold: 10

    readonly property var levels: [left, right].filter(v => v >= 0)
    readonly property int worst: levels.length > 0 ? Math.min(...levels) : -1

    readonly property bool leftLow: present && left >= 0 && left < lowThreshold
    readonly property bool rightLow: present && right >= 0 && right < lowThreshold
    readonly property bool low: leftLow || rightLow

    // Names only the bud(s) actually in trouble - "L 8%" is more use at a glance
    // than a combined number that hides which side is about to cut out.
    readonly property string lowLabel: {
        if (leftLow && rightLow) return `L ${left}%  R ${right}%`;
        if (leftLow) return `L ${left}%`;
        if (rightLow) return `R ${right}%`;
        return "";
    }

    function slotText(value) {
        return value >= 0 ? value + "%" : "--";
    }

    readonly property string summary: `L ${slotText(left)}  R ${slotText(right)}`

    function iconFor(value) {
        if (value < 0) return "󰂑";
        if (value >= 90) return "󰁹";
        if (value >= 70) return "󰂂";
        if (value >= 50) return "󰁿";
        if (value >= 30) return "󰁼";
        if (value >= 15) return "󰁺";
        return "󰂎";
    }

    // Shows the detailed notification, so the warning chip has somewhere to go.
    function notifyLevels() {
        notifier.running = true;
    }

    Process {
        id: notifier
        command: ["bash", Paths.sharedScript("inzone-battery-notify.sh")]
    }

    Process {
        id: probe
        command: [Paths.sharedScript("inzone-battery.py"), "--json"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                let parsed;
                try {
                    parsed = JSON.parse(data);
                } catch (e) {
                    return;
                }

                // JSON null (bud not reporting) and a missing key both collapse
                // to -1; ?? deliberately keeps a real 0 intact.
                root.left = parsed.left ?? -1;
                root.right = parsed.right ?? -1;
                root.caseLevel = parsed["case"] ?? -1;
                root.present = true;
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.present = false;
                root.left = -1;
                root.right = -1;
                root.caseLevel = -1;
            }
        }
    }

    // The underlying value only changes every few minutes, so this is about
    // noticing the daemon's writes promptly, not about resolution.
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
