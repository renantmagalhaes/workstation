pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool open: false
    property var allClients: []
    property var allMonitors: []
    property int stamp: 0
    property string searchQuery: ""
    readonly property bool isSearching: searchQuery.trim().length > 0

    property string activeMonitorName: ""
    readonly property string focusedMonitor: activeMonitorName

    readonly property var orderedMonitors: {
        const screens = Quickshell.screens.slice();
        screens.sort((a, b) => a.x - b.x);
        return screens.map(s => s.name);
    }

    function setActiveMonitor(monName): void {
        if (root.activeMonitorName !== monName) {
            root.activeMonitorName = monName;
        }
    }

    function switchMonitor(direction): void {
        const list = orderedMonitors;
        if (list.length <= 1) return;
        const idx = list.indexOf(root.activeMonitorName);
        if (idx === -1) {
            root.activeMonitorName = list[0];
            return;
        }
        if (direction === "right" && idx < list.length - 1) {
            root.activeMonitorName = list[idx + 1];
        } else if (direction === "left" && idx > 0) {
            root.activeMonitorName = list[idx - 1];
        }
    }

    Process {
        id: shotProcess
        command: ["/home/rtm/.dotfiles/mangowm/scripts/overview_snapshot.sh", "/tmp/quickshell-overview"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.allClients = data.clients ?? [];
                    root.allMonitors = data.monitors ?? [];
                    root.stamp++;
                    const activeMon = data.monitors?.find(m => m.active)?.name;
                    root.activeMonitorName = activeMon ?? Quickshell.screens[0]?.name ?? "DP-1";
                    LauncherManager.closeLauncher();
                    WallpaperManager.closePicker();
                    root.open = true;
                } catch (e) {
                    console.log("Overview snapshot parse error:", e);
                }
            }
        }
    }

    onOpenChanged: {
        if (!open) {
            searchQuery = "";
        }
    }

    function toggle(): void {
        if (root.open) {
            root.closeOverview();
        } else {
            shotProcess.running = false;
            shotProcess.running = true;
        }
    }

    function openOverview(): void {
        if (!root.open) {
            shotProcess.running = false;
            shotProcess.running = true;
        }
    }

    function closeOverview(): void {
        root.open = false;
        root.searchQuery = "";
        root.allClients = [];
        root.allMonitors = [];
        if (typeof gc === "function") {
            Qt.callLater(gc);
        }
    }

    function removeClient(cid): void {
        root.allClients = root.allClients.filter(c => c.id !== cid);
    }

    function updateClientTag(cid, tagId): void {
        root.allClients = root.allClients.map(cl => {
            if (cl.id === cid) {
                return Object.assign({}, cl, { tags: [tagId] });
            }
            return cl;
        });
    }

    IpcHandler {
        target: "overview"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.openOverview();
        }

        function close(): void {
            root.closeOverview();
        }
    }
}
