pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Services"
import "Calculator.js" as Calc

Singleton {
    id: root

    property bool open: false
    property string mode: "all" // "all" | "windows" | "apps"
    property string searchQuery: ""
    property string activeMonitorName: ""
    readonly property string focusedMonitor: activeMonitorName

    property var allClients: []
    property var allApps: []
    property var calcResult: null

    onSearchQueryChanged: {
        calcResult = Calc.calculate(searchQuery);
    }

    onOpenChanged: {
        if (!open) {
            searchQuery = "";
            calcResult = null;
        } else {
            refreshClients();
        }
    }

    function toggle(): void {
        if (root.open) {
            root.closeLauncher();
        } else {
            root.openLauncher();
        }
    }

    function openLauncher(): void {
        // Find currently focused monitor
        const mon = Mango.focusedMonitor || (Quickshell.screens[0]?.name ?? "DP-1");
        root.activeMonitorName = mon;
        root.open = true;
        refreshClients();
    }

    function closeLauncher(): void {
        root.open = false;
        root.searchQuery = "";
        root.calcResult = null;
    }

    function cycleMode(forward): void {
        const modes = ["all", "windows", "apps"];
        let idx = modes.indexOf(root.mode);
        if (idx === -1) idx = 0;
        if (forward) {
            root.mode = modes[(idx + 1) % modes.length];
        } else {
            root.mode = modes[(idx - 1 + modes.length) % modes.length];
        }
    }

    function setMode(newMode): void {
        if (newMode === "all" || newMode === "windows" || newMode === "apps") {
            root.mode = newMode;
        }
    }

    // Refresh client list from MangoWM IPC
    function refreshClients(): void {
        if (!clientsProc.running) {
            clientsProc.running = true;
        }
    }

    Process {
        id: clientsProc
        command: ["mmsg", "get", "all-clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.allClients = (data.clients ?? []).filter(c => !c.is_swallowedby && c.width > 50 && c.height > 50);
                } catch(e) {}
            }
        }
    }

    // Continuous watch for window changes
    Process {
        running: true
        command: ["mmsg", "watch", "all-clients"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    if (Array.isArray(parsed.clients)) {
                        root.allClients = parsed.clients.filter(c => !c.is_swallowedby && c.width > 50 && c.height > 50);
                    }
                } catch(e) {}
            }
        }
    }

    // Focus an open window
    function focusWindow(client): void {
        root.closeLauncher();
        if (!client) return;
        let targetTag = 1;
        if (client.tags && Array.isArray(client.tags) && client.tags.length > 0) {
            targetTag = client.tags[0];
        } else if (typeof client.tag === "number") {
            targetTag = client.tag;
        }
        Quickshell.execDetached(["sh", "-c", `mmsg dispatch focusmon,${client.monitor}; mmsg dispatch view,${targetTag},1; mmsg dispatch focusid client,${client.id}`]);
    }

    // Close / kill a window
    function killWindow(client): void {
        if (!client) return;
        Quickshell.execDetached(["mmsg", "dispatch", "killclient", `client,${client.id}`]);
        root.allClients = (root.allClients || []).filter(c => c.id !== client.id);
        Qt.callLater(() => root.refreshClients());
    }

    // Launch a new instance of an app from a window client
    function launchWindowApp(client): void {
        root.closeLauncher();
        if (!client) return;
        const appid = (client.appid || "").toLowerCase();
        const baseAppid = appid.split(/[-_.]/)[0];

        // 1. Try finding in allApps by desktop ID
        let app = root.allApps.find(a => {
            const id = (a.id || "").toLowerCase().replace(/\.desktop$/, "");
            return id === appid || appid.startsWith(id) || id.startsWith(appid);
        });

        // 2. Try finding by base name (e.g. vivaldi from vivaldi-snapshot)
        if (!app && baseAppid && baseAppid.length > 2) {
            app = root.allApps.find(a => {
                const id = (a.id || "").toLowerCase().replace(/\.desktop$/, "");
                return id === baseAppid || id.startsWith(baseAppid);
            });
        }

        // 3. Try finding by name or command
        if (!app) {
            app = root.allApps.find(a => {
                const name = (a.name || "").toLowerCase();
                const exec = (a.execString || a.command?.[0] || "").toLowerCase();
                const baseExec = exec.split("/").pop();
                return name === appid || exec === appid || baseExec === appid || (baseAppid && baseExec === baseAppid);
            });
        }

        if (app) {
            root.launchApp(app);
            return;
        }

        // 4. Fallback: launch client.appid directly
        if (appid.startsWith("kitty")) {
            Quickshell.execDetached(["kitty"]);
        } else if (client.appid) {
            Quickshell.execDetached(["sh", "-c", `${client.appid} &`]);
        }
    }

    // Launch an application entry
    function launchApp(app): void {
        root.closeLauncher();
        if (!app) return;
        if (app.runInTerminal) {
            Quickshell.execDetached({
                command: ["kitty", "-1", "-e", ...app.command],
                workingDirectory: app.workingDirectory || Quickshell.env("HOME")
            });
        } else if (typeof app.execute === "function") {
            app.execute();
        } else if (app.command) {
            Quickshell.execDetached({
                command: app.command,
                workingDirectory: app.workingDirectory || Quickshell.env("HOME")
            });
        }
    }

    // Copy calculation result
    function copyCalc(result): void {
        root.closeLauncher();
        if (result === undefined || result === null) return;
        Quickshell.execDetached(["wl-copy", String(result)]);
    }

    // Resolve app icon path for a window client
    function getWindowIcon(client): string {
        if (!client) return "";
        const appid = (client.appid || "").toLowerCase();
        let p = Quickshell.iconPath(client.appid, true);
        if (p) return p;

        const app = root.allApps.find(a => {
            const id = (a.id || "").toLowerCase().replace(/\.desktop$/, "");
            return id === appid || appid.startsWith(id) || id.startsWith(appid);
        });
        if (app && app.icon) {
            p = Quickshell.iconPath(app.icon, true);
            if (p) return p;
        }
        return "";
    }

    // Load and update applications list
    function updateApps(): void {
        const raw = DesktopEntries.applications.values ?? [];
        root.allApps = raw.filter(a => !a.noDisplay && a.name);
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root.updateApps();
        }
    }

    Component.onCompleted: {
        root.updateApps();
    }

    // IPC interface for keybinds and scripts
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.openLauncher();
        }

        function close(): void {
            root.closeLauncher();
        }

        function mode(newMode: string): void {
            root.setMode(newMode);
        }
    }
}
