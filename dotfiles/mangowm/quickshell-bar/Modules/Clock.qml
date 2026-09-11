import QtQuick
import Quickshell
import "../Config"

Item {
    id: root

    property bool active: false
    signal activated

    implicitWidth: row.implicitWidth + Theme.capsulePadH * 2
    implicitHeight: Theme.islandHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

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

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.fg
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "ddd d MMM")
            color: Theme.fgDim
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
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
