pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history manager backed by cliphist and wl-copy
Singleton {
    id: root

    property var items: [] // [{ line, text, isImage }]
    property bool loading: false

    function refresh(): void {
        if (!listProc.running) {
            loading = true;
            listProc.running = true;
        }
    }

    function copy(line): void {
        if (!line) return;
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "sh", line]);
    }

    function remove(line): void {
        if (!line) return;
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist delete', "sh", line]);
        items = (items || []).filter(i => i.line !== line);
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                const raw = text.split("\n").filter(l => l.trim().length > 0).slice(0, 150);
                root.items = raw.map(l => {
                    const tabIdx = l.indexOf("\t");
                    const id = tabIdx !== -1 ? l.slice(0, tabIdx) : "";
                    const content = tabIdx !== -1 ? l.slice(tabIdx + 1) : l;
                    const isImg = content.startsWith("[[ binary");
                    let cleanText = content;
                    if (isImg) {
                        const dim = content.match(/\d+x\d+/);
                        cleanText = "Image " + (dim ? dim[0] : "");
                    }
                    return {
                        id: id,
                        line: l,
                        text: cleanText,
                        isImage: isImg
                    };
                });
            }
        }
        onExited: {
            root.loading = false;
        }
    }
}
