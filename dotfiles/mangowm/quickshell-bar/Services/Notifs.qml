pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Notification state, read from mako.
//
// mako already owns the freedesktop notification bus, so the bar talks to it
// through makoctl instead of standing up a competing NotificationServer.
Singleton {
    id: root

    property int count: 0
    property bool dnd: false

    readonly property bool hasUnread: count > 0
    readonly property string icon: dnd ? "󰂛" : count > 0 ? "󰂚" : "󰂜"

    function restore() {
        act("makoctl restore");
    }

    function dismissAll() {
        act("makoctl dismiss --all");
    }

    function toggleDnd() {
        act(dnd ? "makoctl mode -r do-not-disturb" : "makoctl mode -a do-not-disturb");
    }

    function act(command) {
        runner.running = false;
        runner.command = ["sh", "-c", command];
        runner.running = true;
        // Reflect the change without waiting for the next poll tick.
        refreshSoon.restart();
    }

    Process {
        id: runner
    }

    Timer {
        id: refreshSoon
        interval: 150
        onTriggered: probe.running = true
    }

    Process {
        id: probe
        command: ["bash", Paths.script("notifs.sh")]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    root.count = parsed.count ?? 0;
                    root.dnd = parsed.dnd === true;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
