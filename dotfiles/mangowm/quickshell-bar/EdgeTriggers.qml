pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "Config"

Scope {
    id: root

    required property var screen

    property real lastScrollTime: 0

    function handleScroll(direction) {
        const now = Date.now();
        if (now - lastScrollTime < 25) return;
        lastScrollTime = now;
        Quickshell.execDetached(["/home/rtm/.dotfiles/mangowm/scripts/change_workspace.sh", direction]);
    }

    function handleMenu(edge) {
        Quickshell.execDetached(["/home/rtm/.dotfiles/mangowm/scripts/mango-menu.sh", edge]);
    }

    // Top Trigger Panel (height: 2px)
    PanelWindow {
        id: topTrigger
        screen: root.screen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "trigger-top"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 2
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            hoverEnabled: false

            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.handleMenu("top");
                }
            }

            onWheel: wheel => {
                if (wheel.angleDelta.y > 0) {
                    root.handleScroll("left");
                } else if (wheel.angleDelta.y < 0) {
                    root.handleScroll("right");
                }
            }
        }
    }

    // Bottom Trigger Panel (height: 2px)
    PanelWindow {
        id: bottomTrigger
        screen: root.screen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "trigger-bottom"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            bottom: true
            left: true
            right: true
        }

        implicitHeight: 2
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            hoverEnabled: false

            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.handleMenu("bottom");
                }
            }

            onWheel: wheel => {
                if (wheel.angleDelta.y > 0) {
                    root.handleScroll("left");
                } else if (wheel.angleDelta.y < 0) {
                    root.handleScroll("right");
                }
            }
        }
    }
}

