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
        setProc.command = ["sh", "-c", setScript, "sh", filePath];
        setProc.running = true;
    }

    // Prefers awww (fade transition), falls back to swaybg (in the Debian repos)
    readonly property string setScript: `
        f="$1"
        if command -v awww >/dev/null 2>&1; then
            pgrep -x awww-daemon >/dev/null || { setsid awww-daemon >/dev/null 2>&1 & sleep 0.3; }
            exec awww img "$f" --transition-type fade --transition-duration 1
        elif command -v swaybg >/dev/null 2>&1; then
            old=$(pgrep -x swaybg)
            setsid swaybg -m fill -i "$f" >/dev/null 2>&1 &
            sleep 0.5
            [ -n "$old" ] && kill $old
        else
            echo "no wallpaper backend found (install awww or swaybg)" >&2
            exit 1
        fi
    `

    Process {
        id: setProc
        stderr: SplitParser {
            onRead: data => console.warn("[Wallpapers]", data)
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("[Wallpapers] setting wallpaper failed, exit code", code);
        }
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
