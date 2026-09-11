pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU load, memory, disk and temperatures, refreshed from scripts/sysinfo.sh.
//
// The values come from a helper script rather than FileView because /proc
// files report size 0 (so they don't read reliably) and the temperatures need
// `sensors` anyway. One short-lived process every few seconds is cheap.
Singleton {
    id: root

    property real load1: 0
    property int cores: 1
    property int memUsedMib: 0
    property int memTotalMib: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property var temps: ({})

    readonly property real cpuRatio: cores > 0 ? Math.min(1, load1 / cores) : 0
    readonly property real memRatio: memTotalMib > 0 ? memUsedMib / memTotalMib : 0
    readonly property real diskRatio: diskTotal > 0 ? diskUsed / diskTotal : 0

    readonly property var cpuTemp: temps.cpu ?? null
    readonly property var gpuTemp: temps.gpu ?? null
    readonly property var nvmeTemp: temps.nvme ?? null

    // Hottest sensor drives the collapsed chip.
    readonly property var peakTemp: {
        const values = [cpuTemp, gpuTemp, nvmeTemp].filter(t => typeof t === "number");
        return values.length ? Math.max(...values) : null;
    }

    function gib(mib) {
        return (mib / 1024).toFixed(1);
    }

    function gibFromBytes(bytes) {
        return (bytes / (1024 * 1024 * 1024)).toFixed(0);
    }

    Process {
        id: probe
        command: ["bash", Paths.script("sysinfo.sh")]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    root.load1 = parsed.load1 ?? 0;
                    root.cores = parsed.cores ?? 1;
                    root.memUsedMib = parsed.memUsedMib ?? 0;
                    root.memTotalMib = parsed.memTotalMib ?? 0;
                    root.diskUsed = parsed.diskUsed ?? 0;
                    root.diskTotal = parsed.diskTotal ?? 0;
                    root.temps = parsed.temps ?? {};
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
