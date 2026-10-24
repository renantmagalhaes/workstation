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

    readonly property string focusedMonitor: {
        if (!allMonitors || allMonitors.length === 0) {
            return Quickshell.screens[0]?.name ?? "DP-1";
        }
        const m = allMonitors.find(mon => mon.active);
        return m ? m.name : (Quickshell.screens[0]?.name ?? "DP-1");
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
        } else if (!shotProcess.running) {
            shotProcess.running = true;
        }
    }

    function openOverview(): void {
        if (!root.open && !shotProcess.running) {
            shotProcess.running = true;
        }
    }

    function closeOverview(): void {
        root.open = false;
        root.searchQuery = "";
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
