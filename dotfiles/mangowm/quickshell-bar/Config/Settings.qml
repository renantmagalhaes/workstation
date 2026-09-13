pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Persisted UI preferences.
//
// Kept in XDG config rather than in the dotfiles repo: these change at runtime
// (clicking a theme writes the file), and a git tree is the wrong place for
// state that rewrites itself. The file is watched, so editing it by hand also
// applies live.
Singleton {
    id: root

    property string theme: "obsidian"
    property bool blur: false

    // Nothing is written before the first load completes, otherwise the
    // defaults would overwrite a real file during startup.
    property bool loaded: false
    property bool applying: false

    readonly property string path: `${Quickshell.env("HOME")}/.config/quickshell-bar/settings.json`

    function apply(raw) {
        applying = true;
        try {
            const data = JSON.parse(raw);
            if (typeof data.theme === "string") root.theme = data.theme;
            root.blur = data.blur === true;
        } catch (e) {}
        applying = false;
        loaded = true;
    }

    function save() {
        if (!loaded || applying) return;
        file.setText(JSON.stringify({
            theme: root.theme,
            blur: root.blur
        }, null, 2) + "\n");
    }

    onThemeChanged: save()
    onBlurChanged: save()

    FileView {
        id: file

        path: root.path
        blockLoading: true
        atomicWrites: true
        watchChanges: true
        printErrors: false

        onLoaded: root.apply(text())
        onFileChanged: reload()
        // No file yet -- defaults stand, and the first change writes one.
        onLoadFailed: root.loaded = true
    }
}
