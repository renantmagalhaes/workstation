//@ pragma IconTheme Papirus
import QtQuick
import Quickshell
import Quickshell.Wayland
import "MenuData.js" as MenuData

// Tree-style right-click context menu, replacing the rofi-based
// mango-menu-rofi.sh. Launched fresh per invocation by mango-menu.sh, which
// sets MENU_MONITOR (mango output name) and MENU_CURSOR_X/Y (cursor
// position local to that monitor) so the menu opens right at the cursor,
// like a normal right-click menu, instead of an edge-anchored popup.
ShellRoot {
    id: root

    readonly property string monitorName: Quickshell.env("MENU_MONITOR") || ""
    readonly property real cursorX: Number(Quickshell.env("MENU_CURSOR_X")) || 0
    readonly property real cursorY: Number(Quickshell.env("MENU_CURSOR_Y")) || 0

    function targetScreen() {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === root.monitorName)
                return Quickshell.screens[i];
        }
        return Quickshell.screens[0];
    }

    PanelWindow {
        id: win
        screen: root.targetScreen()
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "mango-menu"
        // The waybar trigger strips run on the "overlay" layer (see
        // trigger_config.jsonc) and the main bar on "top" - both of which
        // otherwise render above a "Top"-layer menu near the screen edge,
        // clipping/hiding whichever rows land underneath them.
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Dismiss on any click that isn't consumed by a menu row.
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Qt.quit()

            MenuLevel {
                id: rootMenu
                items: MenuData.menu
                screenSize: Qt.size(win.width, win.height)
                depth: 0

                // Open right where the cursor is, clamped so it never
                // overflows the edge of the monitor (flips up/left near a
                // screen edge, like a normal desktop context menu).
                x: Math.max(8, Math.min(root.cursorX, win.width - width - 8))
                y: Math.max(8, Math.min(root.cursorY, win.height - height - 8))

                onRequestClose: Qt.quit()
            }
        }
    }
}
