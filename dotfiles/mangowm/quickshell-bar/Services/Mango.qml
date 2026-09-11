pragma Singleton

import Quickshell
import Quickshell.Io

// MangoWM state, sourced from the compositor's JSON IPC socket via `mmsg`.
//
// `mmsg watch all-monitors` streams one newline-delimited snapshot of every
// monitor on each change, so there is nothing to poll. Mango is a dwl
// descendant and calls workspaces "tags"; we surface them as workspaces.
Singleton {
    id: root

    // monitor name -> array of { index, is_active, is_urgent, layout, client_count }
    property var tagsByMonitor: ({})
    // monitor name -> true while that output is showing the overview
    property var overviewByMonitor: ({})
    property string focusedMonitor: ""

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
                let focused = root.focusedMonitor;

                for (const monitor of parsed.monitors) {
                    tags[monitor.name] = monitor.tags ?? [];

                    // Mango reports active_tags [] or [0] while the overview is
                    // open, meaning no real tag is selected.
                    const active = monitor.active_tags ?? [];
                    overview[monitor.name] = active.length === 0 || active.every(t => t === 0);

                    if (monitor.active) focused = monitor.name;
                }

                root.tagsByMonitor = tags;
                root.overviewByMonitor = overview;
                root.focusedMonitor = focused;
            }
        }
    }
}
