pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Services"
import "Calculator.js" as Calc

Singleton {
    id: root

    property bool open: false
    // Modes: all | windows | apps | shortcuts
    property string mode: "all"
    property string searchQuery: ""
    property string activeMonitorName: ""
    readonly property string focusedMonitor: activeMonitorName

    property var allClients: []
    property var allApps: []
    property var calcResult: null
    property var filesResults: []
    property bool filesSearching: false

    readonly property var availableModes: [
        { id: "all", icon: "󰕰", label: "All" },
        { id: "windows", icon: "󱂬", label: "Windows" },
        { id: "apps", icon: "󰀻", label: "Apps" },
        { id: "shortcuts", icon: "󰌌", label: "Shortcuts" }
    ]

    // Effective kind: prefixes take precedence
    readonly property string kind: {
        const q = searchQuery.trim();
        if (q.startsWith(">") || q.startsWith("$")) return "cmd";
        if (q.startsWith("/")) return "files";
        if (q.startsWith("?")) return "web";
        if (q.startsWith("=")) return "calc";
        return mode;
    }

    onSearchQueryChanged: {
        calcResult = Calc.calculate(searchQuery);
        if (searchQuery.trim().startsWith("/")) {
            filesDebounce.restart();
        } else {
            filesResults = [];
        }
    }

    onOpenChanged: {
        if (!open) {
            searchQuery = "";
            calcResult = null;
            filesResults = [];
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
        WallpaperManager.closePicker();
        OverviewManager.closeOverview();
        const mon = Mango.focusedMonitor || (Quickshell.screens[0]?.name ?? "DP-1");
        root.activeMonitorName = mon;
        root.open = true;
        refreshClients();
    }

    function closeLauncher(): void {
        root.open = false;
        root.searchQuery = "";
        root.calcResult = null;
        root.filesResults = [];
    }

    function cycleMode(forward): void {
        const ids = availableModes.map(m => m.id);
        let idx = ids.indexOf(root.mode);
        if (idx === -1) idx = 0;
        if (forward) {
            root.mode = ids[(idx + 1) % ids.length];
        } else {
            root.mode = ids[(idx - 1 + ids.length) % ids.length];
        }
    }

    function setMode(newMode): void {
        const found = availableModes.some(m => m.id === newMode);
        if (found) {
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

        let app = root.allApps.find(a => {
            const id = (a.id || "").toLowerCase().replace(/\.desktop$/, "");
            return id === appid || appid.startsWith(id) || id.startsWith(appid);
        });

        if (!app && baseAppid && baseAppid.length > 2) {
            app = root.allApps.find(a => {
                const id = (a.id || "").toLowerCase().replace(/\.desktop$/, "");
                return id === baseAppid || id.startsWith(baseAppid);
            });
        }

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

    // Execute shell command
    function executeCommand(cmd, inTerminal): void {
        root.closeLauncher();
        const c = (cmd || "").replace(/^[>$]\s*/, "").trim();
        if (!c) return;
        if (inTerminal) {
            Quickshell.execDetached([
                "kitty", "-1", "--class", "kitty-float", "-e", "sh", "-c",
                c + '; echo; read -n1 -p "Press any key to close..."'
            ]);
        } else {
            Quickshell.execDetached(["sh", "-c", c]);
        }
    }

    // Web search
    function searchWeb(query): void {
        root.closeLauncher();
        const q = (query || "").replace(/^\?\s*/, "").trim();
        if (!q) return;
        Quickshell.execDetached(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(q)]);
    }

    // File open
    function openFile(path, inFolder): void {
        root.closeLauncher();
        if (!path) return;
        if (inFolder) {
            const lastSlash = path.lastIndexOf("/");
            const parentDir = lastSlash > 0 ? path.slice(0, lastSlash) : Quickshell.env("HOME");
            Quickshell.execDetached(["xdg-open", parentDir]);
        } else {
            Quickshell.execDetached(["xdg-open", path]);
        }
    }

    // File search debounce & process
    Timer {
        id: filesDebounce
        interval: 100
        onTriggered: {
            const raw = root.searchQuery.trim();
            if (!raw.startsWith("/")) {
                root.filesResults = [];
                return;
            }
            const query = raw.slice(1).trim();
            if (!query) {
                root.filesResults = [];
                return;
            }
            filesProc.targetQuery = query;
            filesProc.running = true;
        }
    }

    Process {
        id: filesProc
        property string targetQuery: ""
        command: [
            "sh", "-c",
            'PATH="$HOME/.nix-profile/bin:$PATH"; fd --fixed-strings --ignore-case --max-results 30 --absolute-path "$1" "$HOME"',
            "sh", targetQuery
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.trim().length > 0);
                const home = Quickshell.env("HOME");
                root.filesResults = lines.map(p => {
                    const isDir = p.endsWith("/");
                    const clean = isDir ? p.slice(0, -1) : p;
                    const slashIdx = clean.lastIndexOf("/");
                    const name = slashIdx !== -1 ? clean.slice(slashIdx + 1) : clean;
                    const parent = slashIdx !== -1 ? clean.slice(0, slashIdx) : home;
                    return {
                        path: clean,
                        name: name,
                        parent: parent.replace(home, "~"),
                        isDir: isDir
                    };
                });
            }
        }
    }

    // System actions list
    readonly property var systemActions: [
        { id: "wallpaper", title: "Open Wallpaper Picker", subtitle: "Browse and set desktop wallpapers", icon: "󰸉", color: "#F472B6", command: ["sh", "-c", "~/.dotfiles/mangowm/scripts/toggle_wallpapers.sh"], keywords: ["wallpaper", "wall", "paper"] },
        { id: "lock", title: "Lock Screen", subtitle: "Lock Wayland session", icon: "󰌾", color: "#60A5FA", command: ["loginctl", "lock-session"], keywords: ["lock"] },
        { id: "suspend", title: "Suspend", subtitle: "Suspend session to RAM", icon: "󰒲", color: "#FBBF24", command: ["systemctl", "suspend"], confirm: true, confirmPrompt: "Put computer into suspend mode?", keywords: ["suspend"] },
        { id: "sleep", title: "Sleep", subtitle: "Put computer to sleep", icon: "󰒲", color: "#FBBF24", command: ["systemctl", "suspend"], confirm: true, confirmPrompt: "Put computer to sleep?", keywords: ["sleep", "suspend"] },
        { id: "reboot", title: "Reboot System", subtitle: "Restart the workstation", icon: "󰜉", color: "#F97316", command: ["systemctl", "reboot"], confirm: true, confirmPrompt: "Restart the workstation?", keywords: ["reboot", "restart"] },
        { id: "shutdown", title: "Shut Down", subtitle: "Turn off the workstation", icon: "󰐥", color: "#EF4444", command: ["systemctl", "poweroff"], confirm: true, confirmPrompt: "Turn off the workstation?", keywords: ["shutdown", "poweroff", "power", "shut down"] },
        { id: "reload", title: "Reload MangoWM", subtitle: "Reload window manager configuration", icon: "󰑓", color: "#34D399", command: ["mmsg", "dispatch", "reload_config"], keywords: ["reload", "refresh"] },
        { id: "logout", title: "Log Out", subtitle: "Exit desktop session", icon: "󰗽", color: "#F43F5E", command: ["mmsg", "dispatch", "quit"], confirm: true, confirmPrompt: "Exit current desktop session?", keywords: ["logout", "quit", "exit", "log out"] }
    ]

    function executeSystemAction(action): void {
        root.closeLauncher();
        if (!action || !action.command) return;
        Quickshell.execDetached(action.command);
    }

    // MangoWM shortcuts database
    readonly property var shortcuts: [
        { key: "Super + Q", title: "Smart Close Window", desc: "Close window or untag", category: "Window" },
        { key: "Alt + Space", title: "Spotlight Launcher", desc: "Open QuickShell apps & utilities", category: "Launcher" },
        { key: "Super + W", title: "Wallpaper Picker", desc: "Dedicated wallpaper browser & changer", category: "Launcher" },
        { key: "Super + Tab", title: "Window Overview", desc: "Toggle visual overview of monitor", category: "Navigation" },
        { key: "Super + Shift + Tab", title: "All Overviews", desc: "Toggle overview across all monitors", category: "Navigation" },
        { key: "Ctrl + Alt + T", title: "Open Kitty Terminal", desc: "Launch primary terminal", category: "App" },
        { key: "Ctrl + Enter", title: "Kitty Scratchpad", desc: "Toggle floating scratchpad terminal", category: "App" },
        { key: "Super + Enter", title: "Move to Other Monitor", desc: "Send window to opposite monitor", category: "Window" },
        { key: "Alt + Tab", title: "Focus Other Monitor", desc: "Switch focus to adjacent monitor", category: "Navigation" },
        { key: "Super + L", title: "Lock Screen", desc: "Lock current session", category: "Session" },
        { key: "Print", title: "Screenshot Selection", desc: "Capture area with grim & swappy", category: "Utility" },
        { key: "Super + V", title: "Clipboard Menu", desc: "Open CopyQ / clipboard history", category: "Utility" },
        { key: "Super + T", title: "Toggle Floating", desc: "Float or tile active window", category: "Window" },
        { key: "Super + M", title: "Switch Proportion", desc: "Cycle window size preset", category: "Layout" },
        { key: "Super + Shift + M", title: "Toggle Fullscreen", desc: "Toggle fullscreen window state", category: "Layout" },
        { key: "Super + F", title: "Set Proportion 1.0", desc: "Fill available layout width", category: "Layout" },
        { key: "Super + 1 .. 5", title: "Switch Workspace", desc: "Switch to workspace / tag 1-5", category: "Navigation" },
        { key: "Super + Ctrl + Left / Right", title: "Cycle Workspaces", desc: "Navigate adjacent workspaces", category: "Navigation" },
        { key: "Super + Shift + 1 .. 5", title: "Move to Workspace", desc: "Send window to workspace 1-5", category: "Window" },
        { key: "Super + C", title: "Play / Pause Media", desc: "Toggle audio/video playback", category: "Media" },
        { key: "Super + R", title: "Reload Config", desc: "Reload MangoWM configuration", category: "System" },
        { key: "Super + Alt + Esc", title: "Quit MangoWM", desc: "Exit compositor session", category: "System" }
    ]

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
        root.allApps = raw.filter(a => !a.noDisplay && a.name && !((a.id || "").startsWith("power-menu")));
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
