import QtQuick
import "../Config"

// Overview (Task View / Mission Control) button in the Dynamic Island.
// Left-click toggles the Mission Control overview.
Item {
    id: root

    property bool active: OverviewManager.open
    signal activated

    implicitWidth: Theme.islandHeight - 6
    implicitHeight: Theme.islandHeight

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        radius: Theme.chipRadius
        color: (root.active || mouse.pressed) ? Theme.pressed : mouse.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󱂬"
        color: root.active ? Theme.accent : mouse.containsMouse ? Theme.fg : Theme.fgDim
        font.family: Theme.iconFamily
        renderType: Text.QtRendering
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.activated()
    }
}
