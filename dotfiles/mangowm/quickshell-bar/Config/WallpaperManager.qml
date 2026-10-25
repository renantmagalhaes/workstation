pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Services"

Singleton {
    id: root

    property bool open: false
    property string searchQuery: ""
    property string activeMonitorName: ""
    readonly property string focusedMonitor: activeMonitorName

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
        root.open = true;
        Wallpapers.refreshCurrent();
    }

    function closePicker(): void {
        root.open = false;
        root.searchQuery = "";
    }

    function setRandomWallpaper(): void {
        const list = Wallpapers.list || [];
        if (list.length === 0) return;
        const randomItem = list[Math.floor(Math.random() * list.length)];
        if (randomItem && randomItem.path) {
            Wallpapers.setWallpaper(randomItem.path);
        }
    }

    IpcHandler {
        target: "wallpapers"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.openPicker();
        }

        function close(): void {
            root.closePicker();
        }

        function random(): void {
            root.setRandomWallpaper();
        }
    }
}
