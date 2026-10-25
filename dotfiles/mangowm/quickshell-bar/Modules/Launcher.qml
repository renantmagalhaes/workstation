pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Config"

PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: LauncherManager.open

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: (LauncherManager.open && (LauncherManager.activeMonitorName === monName)) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string monName: win.screen?.name ?? "DP-1"
    readonly property bool isTargetMonitor: LauncherManager.activeMonitorName === monName

    // Dark backdrop scrim covering the monitor
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: LauncherManager.open ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        // Clicking backdrop closes launcher
        MouseArea {
            anchors.fill: parent
            onClicked: LauncherManager.closeLauncher()
        }
    }

    // Centered Spotlight card on active monitor
    Item {
        id: cardContainer
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.18)
        width: panel.width
        height: panel.implicitHeight
        visible: win.isTargetMonitor

        // Spring entrance / soft exit animation
        scale: LauncherManager.open ? 1.0 : 0.95
        opacity: LauncherManager.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: LauncherManager.open ? 240 : 160
                easing.type: LauncherManager.open ? Easing.OutBack : Easing.OutQuad
                easing.overshoot: 1.08
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: LauncherManager.open ? 180 : 140
                easing.type: Easing.OutCubic
            }
        }

        // Prevent click-through closing when clicking inside the panel
        MouseArea {
            anchors.fill: parent
        }

        LauncherPanel {
            id: panel
        }
    }
}
