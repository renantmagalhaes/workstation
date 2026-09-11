pragma Singleton

import Quickshell
import Quickshell.Io

// MangoWM state, sourced from the compositor's JSON IPC socket via `mmsg`.
//
// `mmsg watch <thing>` streams one newline-delimited snapshot per change, so
// nothing is polled. Mango is a dwl descendant and calls workspaces "tags";
// we surface them as workspaces.
Singleton {
    id: root

    // ---- Tags --------------------------------------------------------------
    // monitor name -> array of { index, is_active, is_urgent, layout, client_count }
    property var tagsByMonitor: ({})
    // monitor name -> true while that output is showing the overview
    property var overviewByMonitor: ({})
    property string focusedMonitor: ""

    // Output names in the order mango reports them, used to cycle windows.
    property var monitorNames: []
    // monitor name -> layout symbol ("S" is the horizontal scroller)
    property var layoutByMonitor: ({})
    // monitor name -> output width in px
    property var widthByMonitor: ({})

    // Only tags 1-5 are bound to keys in keybinds.conf, so the rest are noise.
    readonly property int visibleTags: 5

    function tagsFor(monitor) {
        return tagsByMonitor[monitor] ?? [];
    }

    function inOverview(monitor) {
        return overviewByMonitor[monitor] ?? false;
    }

    // `view` always acts on the focused monitor -- mango exposes no
    // monitor-targeted variant over IPC (`view_in_mon` is not dispatchable) --
    // so focus the monitor that owns the clicked bar first. Focusing an
    // already-focused monitor is a no-op.
    function focusTag(monitor, index) {
        run(`mmsg dispatch focusmon,${monitor}; mmsg dispatch view,${index},1`);
    }

    // ---- Focused window ----------------------------------------------------
    property var focusedClient: null

    readonly property string windowTitle: focusedClient?.title ?? ""
    readonly property string windowAppId: focusedClient?.appid ?? ""
    readonly property string windowMonitor: focusedClient?.monitor ?? ""
    readonly property int windowWidth: focusedClient?.width ?? 0
    readonly property bool windowFullscreen: focusedClient?.is_fullscreen ?? false
    readonly property bool windowFloating: focusedClient?.is_floating ?? false
    readonly property bool hasWindow: !!focusedClient && windowTitle !== ""

    // ---- Window actions ----------------------------------------------------
    function killActive() {
        dispatch("killclient");
    }

    function toggleFullscreen() {
        dispatch("togglefullscreen");
    }

    // Cycle the focused window to the next output. Done from the streamed
    // monitor list rather than shelling out: the old waybar helper lived under
    // waybar/scripts (which this bar is replacing) and only ever picked the
    // first *inactive* output, so it could not cycle past two monitors.
    function moveToNextMonitor() {
        const names = monitorNames;
        if (names.length < 2) return;

        const current = names.indexOf(focusedMonitor);
        const next = names[(current + 1) % names.length];
        if (next && next !== focusedMonitor) dispatch(`tagmon,${next}`);
    }

    // ---- Scroller layout ---------------------------------------------------
    // The "S" layout scrolls windows horizontally, so some sit off screen with
    // nothing on the bar to say so. This mirrors the rule the old waybar
    // indicator used: three or more windows on the active tag always overflow,
    // and exactly two overflow when the focused one nearly fills the output.
    readonly property int scrollSlack: 40

    function activeTagClients(monitor) {
        let total = 0;
        for (const tag of tagsFor(monitor))
            if (tag.is_active) total += tag.client_count ?? 0;
        return total;
    }

    function scrollableOn(monitor) {
        if ((layoutByMonitor[monitor] ?? "") !== "S") return false;
        if (inOverview(monitor)) return false;

        const clients = activeTagClients(monitor);
        if (clients >= 3) return true;
        if (clients !== 2) return false;

        // The two-window case needs the focused window's width, which is only
        // known for the output that actually owns it.
        if (windowMonitor !== monitor) return false;

        const outputWidth = widthByMonitor[monitor] ?? 0;
        return windowWidth > 0 && outputWidth > 0 && outputWidth - windowWidth <= scrollSlack;
    }

    function focusPrev() {
        dispatch("focusstack,prev");
    }

    function focusNext() {
        dispatch("focusstack,next");
    }

    function dispatch(command) {
        run(`mmsg dispatch ${command}`);
    }

    function run(script) {
        dispatcher.running = false;
        dispatcher.command = ["sh", "-c", script];
        dispatcher.running = true;
    }

    Process {
        id: dispatcher
    }

    Process {
        running: true
        command: ["mmsg", "watch", "all-monitors"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;

                let parsed;
                try {
                    parsed = JSON.parse(data);
                } catch (e) {
                    return; // partial line during compositor churn; next snapshot is full state
                }
                if (!Array.isArray(parsed.monitors)) return;

                const tags = {};
                const overview = {};
                const names = [];
                const layouts = {};
                const widths = {};
                let focused = root.focusedMonitor;

                for (const monitor of parsed.monitors) {
                    names.push(monitor.name);
                    layouts[monitor.name] = monitor.layout_symbol ?? "";
                    widths[monitor.name] = monitor.width ?? 0;
                    tags[monitor.name] = monitor.tags ?? [];

                    // Mango reports active_tags [] or [0] while the overview is
                    // open, meaning no real tag is selected.
                    const active = monitor.active_tags ?? [];
                    overview[monitor.name] = active.length === 0 || active.every(t => t === 0);

                    if (monitor.active) focused = monitor.name;
                }

                root.tagsByMonitor = tags;
                root.overviewByMonitor = overview;
                root.monitorNames = names;
                root.layoutByMonitor = layouts;
                root.widthByMonitor = widths;
                root.focusedMonitor = focused;
            }
        }
    }

    Process {
        running: true
        command: ["mmsg", "watch", "focusing-client"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    const parsed = JSON.parse(data);
                    // An empty object / missing title means nothing is focused.
                    root.focusedClient = parsed && parsed.title !== undefined ? parsed : null;
                } catch (e) {
                    root.focusedClient = null;
                }
            }
        }
    }
}
