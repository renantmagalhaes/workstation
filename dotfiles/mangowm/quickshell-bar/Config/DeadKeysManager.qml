pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Services"

Singleton {
    id: root

    property bool open: false
    property string activeMonitorName: ""
    // Empty while picking the base key, otherwise the key whose variants are shown
    property string selectedKey: ""

    readonly property var table: ({
        "a": "àáâãäªÀÁÂÃÄ",
        "e": "èéêëÈÉÊË",
        "i": "ìíîïÌÍÎÏ",
        "o": "òóôõöºÒÓÔÕÖ",
        "u": "ùúûüÙÚÛÜ",
        "c": "ç©ĉÇĈ",
        "n": "ñńÑŃ",
        "s": "ßẞ"
    })
    readonly property var keys: Object.keys(table)
    readonly property var chars: selectedKey ? Array.from(table[selectedKey] || "") : []

    function toggle(): void {
        if (root.open) {
            root.closePicker();
        } else {
            root.openPicker();
        }
    }

    function openPicker(): void {
        LauncherManager.closeLauncher();
        OverviewManager.closeOverview();
        const mon = Mango.focusedMonitor || (Quickshell.screens[0]?.name ?? "DP-1");
        root.activeMonitorName = mon;
        root.selectedKey = "";
        root.open = true;
    }

    function closePicker(): void {
        root.open = false;
        root.selectedKey = "";
    }

    function chooseKey(key: string): void {
        if (root.table[key] !== undefined)
            root.selectedKey = key;
    }

    function back(): void {
        if (root.selectedKey)
            root.selectedKey = "";
        else
            root.closePicker();
    }

    // Copies to the clipboard, then types into the window that regains focus once the picker closes
    function typeChar(ch: string): void {
        if (!ch) return;
        root.closePicker();
        Quickshell.execDetached(["sh", "-c", `
            printf '%s' "$1" | wl-copy
            sleep 0.2
            wtype "$1" 2>/dev/null || xdotool type "$1"
        `, "sh", ch]);
    }

    IpcHandler {
        target: "deadkeys"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.openPicker();
        }

        function close(): void {
            root.closePicker();
        }
    }
}
