pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU load, memory, disk, temperatures, uptime and network throughput, plus
// static hardware identity.
//
// The values come from helper scripts rather than FileView because /proc files
// report size 0 (so they don't read reliably) and the temperatures need
// `sensors` anyway. One short-lived process every few seconds is cheap; the
// hardware identity is a separate one-shot because `lspci` is far too slow to
// call on the poll timer.
Singleton {
    id: root

    property real load1: 0
    property int cores: 1
    property int memUsedMib: 0
    property int memTotalMib: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property var temps: ({})

    property real uptime: 0
    property string iface: ""

    // Differentiated from the cumulative counters the script reports -- the
    // shell has no memory between runs, so the rate is computed here.
    property real rxRate: 0
    property real txRate: 0

    property string cpuModel: ""
    property string osName: ""
    property string kernel: ""
    property string gpuModel: ""

    property real previousRx: -1
    property real previousTx: -1
    property real previousAt: 0

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

    readonly property string uptimeText: {
        const total = Math.floor(uptime);
        const days = Math.floor(total / 86400);
        const hours = Math.floor((total % 86400) / 3600);
        const minutes = Math.floor((total % 3600) / 60);
        if (days > 0) return `${days}d ${hours}h`;
        return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
    }

    function gib(mib) {
        return (mib / 1024).toFixed(1);
    }

    function gibFromBytes(bytes) {
        return (bytes / (1024 * 1024 * 1024)).toFixed(0);
    }

    function formatRate(bytesPerSecond) {
        const kb = bytesPerSecond / 1024;
        if (kb < 1) return "0 KB/s";
        if (kb < 1024) return `${kb.toFixed(0)} KB/s`;
        return `${(kb / 1024).toFixed(1)} MB/s`;
    }

    Process {
        id: probe
        command: ["bash", Paths.script("sysinfo.sh")]

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

                root.load1 = parsed.load1 ?? 0;
                root.cores = parsed.cores ?? 1;
                root.memUsedMib = parsed.memUsedMib ?? 0;
                root.memTotalMib = parsed.memTotalMib ?? 0;
                root.diskUsed = parsed.diskUsed ?? 0;
                root.diskTotal = parsed.diskTotal ?? 0;
                root.temps = parsed.temps ?? {};
                root.uptime = parsed.uptime ?? 0;
                root.iface = parsed.iface ?? "";

                const now = Date.now() / 1000;
                const rx = parsed.rxBytes ?? 0;
                const tx = parsed.txBytes ?? 0;

                // Skip the first sample (no baseline) and guard against a
                // counter reset when the interface changes.
                if (root.previousRx >= 0 && now > root.previousAt && rx >= root.previousRx) {
                    const elapsed = now - root.previousAt;
                    root.rxRate = Math.max(0, (rx - root.previousRx) / elapsed);
                    root.txRate = Math.max(0, (tx - root.previousTx) / elapsed);
                }
                root.previousRx = rx;
                root.previousTx = tx;
                root.previousAt = now;
            }
        }
    }

    Process {
        running: true
        command: ["bash", Paths.script("sysstatic.sh")]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    root.cpuModel = parsed.cpu ?? "";
                    root.osName = parsed.os ?? "";
                    root.kernel = parsed.kernel ?? "";
                    root.gpuModel = parsed.gpu ?? "";
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
