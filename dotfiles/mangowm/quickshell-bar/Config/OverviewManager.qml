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

    // Cross-monitor drag & drop state
    property var dragged: null
    property real dragGlobalX: 0
    property real dragGlobalY: 0
    property string hoverMonitor: ""
    property int hoverWorkspace: 0
    property var lastMovedClient: null

    property string activeMonitorName: ""
    readonly property string focusedMonitor: activeMonitorName

    readonly property var orderedMonitors: {
        const screens = Quickshell.screens.slice();
        screens.sort((a, b) => a.x - b.x);
        return screens.map(s => s.name);
    }

    function otherMonitorsFor(currentMonName) {
        return Quickshell.screens.slice().filter(s => s.name !== currentMonName);
    }

    function screenAt(gx, gy) {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            const s = screens[i];
            if (gx >= s.x && gx < s.x + s.width && gy >= s.y && gy < s.y + s.height) {
                return s;
            }
        }
        return null;
    }

    function startDrag(client, icon, title, sourceMon, tagText): void {
        root.dragged = {
            client: client,
            icon: icon,
            title: title,
            sourceMonitor: sourceMon,
            tagText: tagText ?? ""
        };
    }

    function updateDragPos(gx, gy): void {
        root.dragGlobalX = gx;
        root.dragGlobalY = gy;
    }

    function clearDrag(): void {
        root.dragged = null;
        root.hoverMonitor = "";
        root.hoverWorkspace = 0;
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
            clearDrag();
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
        root.lastMovedClient = null;
        root.clearDrag();
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
        root.stamp++;
    }

    function updateClientMonitor(cid, targetMon, tagId): void {
        let resolvedTag = tagId;
        if (!resolvedTag || resolvedTag <= 0) {
            const mon = root.allMonitors.find(m => m.name === targetMon);
            if (mon && Array.isArray(mon.active_tags) && mon.active_tags.length > 0 && mon.active_tags[0] > 0) {
                resolvedTag = mon.active_tags[0];
            } else {
                resolvedTag = 1;
            }
        }

        const clientObj = root.allClients.find(c => c.id === cid);
        const sourceMon = clientObj?.monitor ?? "";
        const sourceScreen = Quickshell.screens.find(s => s.name === sourceMon);
        const targetScreen = Quickshell.screens.find(s => s.name === targetMon);

        root.lastMovedClient = {
            id: cid,
            sourceMonitor: sourceMon,
            targetMonitor: targetMon,
            sourceScreenX: sourceScreen ? sourceScreen.x : 0,
            sourceScreenY: sourceScreen ? sourceScreen.y : 0,
            targetScreenX: targetScreen ? targetScreen.x : 0,
            targetScreenY: targetScreen ? targetScreen.y : 0
        };

        const localX = (clientObj && clientObj.x !== undefined && sourceScreen)
            ? (clientObj.x - sourceScreen.x)
            : 100;
        const localY = (clientObj && clientObj.y !== undefined && sourceScreen)
            ? (clientObj.y - sourceScreen.y)
            : 100;

        const newGlobalX = targetScreen ? (targetScreen.x + localX) : (clientObj ? clientObj.x : 0);
        const newGlobalY = targetScreen ? (targetScreen.y + localY) : (clientObj ? clientObj.y : 0);

        root.allClients = root.allClients.map(cl => {
            if (cl.id === cid) {
                return Object.assign({}, cl, {
                    monitor: targetMon,
                    tags: [resolvedTag],
                    x: newGlobalX,
                    y: newGlobalY
                });
            }
            return cl;
        });
        root.stamp++;
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
