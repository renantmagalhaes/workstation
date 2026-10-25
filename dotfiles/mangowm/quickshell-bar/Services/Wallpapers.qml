pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

// Wallpaper service managing ~/Pictures/wallpapers and awww
Singleton {
    id: root

    readonly property string wallpapersFolder: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers"
    property string currentWallpaperPath: ""
    property var list: []
    property bool ready: false

    function refreshCurrent(): void {
        if (!queryProc.running) {
            queryProc.running = true;
        }
    }

    function setWallpaper(filePath): void {
        if (!filePath) return;
        currentWallpaperPath = filePath;
        // Use awww with smooth fade transition
        Quickshell.execDetached([
            "awww", "img", filePath,
            "--transition-type", "fade",
            "--transition-duration", "1"
        ]);
    }

    // Model for wallpaper folder
    FolderListModel {
        id: folderModel
        folder: root.wallpapersFolder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name

        onCountChanged: {
            updateList();
        }
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                updateList();
            }
        }
    }

    function updateList(): void {
        const count = folderModel.count;
        const out = [];
        for (let i = 0; i < count; i++) {
            const fileName = folderModel.get(i, "fileName") || "";
            const filePath = folderModel.get(i, "filePath") || "";
            const fileUrl = folderModel.get(i, "fileUrl") || ("file://" + filePath);
            out.push({
                index: i,
                name: fileName,
                path: filePath,
                url: fileUrl
            });
        }
        root.list = out;
        root.ready = true;
    }

    // Query awww to identify the current wallpaper
    Process {
        id: queryProc
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Example output: ": DP-1: 2560x1440, scale: 1, currently displaying: image: /home/rtm/Pictures/wallpapers/xyz.webp"
                const match = text.match(/image:\s*([^\n\r]+)/);
                if (match && match[1]) {
                    root.currentWallpaperPath = match[1].trim();
                }
            }
        }
    }

    Component.onCompleted: {
        refreshCurrent();
    }
}
