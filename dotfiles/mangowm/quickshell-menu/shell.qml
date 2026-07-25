//@ pragma IconTheme Papirus
import QtQuick
import Quickshell
import Quickshell.Wayland
import "MenuData.js" as MenuData

// Tree-style right-click context menu, replacing the rofi-based
// mango-menu-rofi.sh. Launched fresh per invocation by mango-menu.sh, which
// sets MENU_EDGE ("top"/"bottom") and MENU_MONITOR (mango output name) to
// match whichever trigger bar/monitor the cursor was over.
ShellRoot {
    id: root

    readonly property string edge: Quickshell.env("MENU_EDGE") || "bottom"
    readonly property string monitorName: Quickshell.env("MENU_MONITOR") || ""

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
        WlrLayershell.layer: WlrLayershell.Top
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

                x: 12
                y: root.edge === "top" ? 12 : win.height - height - 12

                onRequestClose: Qt.quit()
            }
        }
    }
}
