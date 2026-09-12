pragma Singleton

import Quickshell

// Resolves helper scripts relative to the shell config directory, so the bar
// keeps working wherever the dotfiles are checked out or symlinked from.
Singleton {
    // Qt.resolvedUrl("..") comes back without a trailing slash, so add one.
    readonly property string configDir: {
        const dir = Qt.resolvedUrl("..").toString().replace(/^file:\/\//, "");
        return dir.endsWith("/") ? dir : dir + "/";
    }

    function script(name) {
        return configDir + "scripts/" + name;
    }

    // Helpers that live with the rest of the MangoWM scripts rather than with
    // the bar, so the bar can reuse them instead of keeping a second copy.
    function sharedScript(name) {
        return configDir + "../scripts/" + name;
    }
}
