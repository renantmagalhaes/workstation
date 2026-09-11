pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Current conditions from wttr.in via scripts/weather.sh.
Singleton {
    id: root

    property bool ok: false
    property int tempC: 0
    property int feelsC: 0
    property int humidity: 0
    property int windKmph: 0
    property int code: 0
    property string description: ""
    property string location: ""

    // World Weather Online condition codes, as used by wttr.in.
    readonly property string icon: {
        if (!ok) return "󰅤";
        const c = code;
        if (c === 113) return "󰖙";                                    // sunny
        if (c === 116) return "󰖕";                                    // partly cloudy
        if ([119, 122].includes(c)) return "󰖐";                        // cloudy / overcast
        if ([143, 248, 260].includes(c)) return "󰖑";                   // fog
        if ([200, 386, 389, 392, 395].includes(c)) return "󰙾";         // thunder
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c)) return "󰖘"; // snow
        if ([182, 185, 281, 284, 311, 314, 317, 320, 350, 362, 365, 374, 377].includes(c)) return "󰙿"; // sleet
        return "󰖗";                                                    // rain
    }

    Process {
        id: probe
        command: ["bash", Paths.script("weather.sh")]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    root.ok = parsed.ok === true;
                    if (!root.ok) return;
                    root.tempC = parsed.tempC ?? 0;
                    root.feelsC = parsed.feelsC ?? 0;
                    root.humidity = parsed.humidity ?? 0;
                    root.windKmph = parsed.windKmph ?? 0;
                    root.code = parsed.code ?? 0;
                    root.description = parsed.desc ?? "";
                    root.location = parsed.location ?? "";
                } catch (e) {
                    root.ok = false;
                }
            }
        }
    }

    function refresh() {
        probe.running = true;
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
