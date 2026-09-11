import QtQuick
import "../Config"

Item {
    id: root

    property bool active: false
    signal activated

    implicitWidth: Theme.islandHeight - 6
    implicitHeight: Theme.islandHeight

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        radius: Theme.chipRadius
        color: root.active ? Theme.pressed : mouse.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: root.active || mouse.containsMouse ? Theme.urgent : Theme.fgDim
        font.family: Theme.iconFamily; renderType: Text.QtRendering
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
        onClicked: root.activated()
    }
}
