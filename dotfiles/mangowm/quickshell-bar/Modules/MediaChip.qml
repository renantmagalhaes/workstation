import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

// Appears in the pill only while something is playable -- the island widening
// when you start music is the whole point of the shape.
Item {
    id: root

    property bool active: false
    signal activated

    readonly property bool present: Media.hasPlayer

    implicitWidth: present ? row.implicitWidth + Theme.capsulePadH * 2 : 0
    implicitHeight: Theme.islandHeight
    visible: present

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durIsland
            easing.type: Easing.OutCubic
        }
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
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Media.playing ? "󰝚" : "󰏤"
            color: Media.playing ? Theme.good : Theme.fgDim
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durSnappy
                }
            }
        }

        ScrollingText {
            anchors.verticalCenter: parent.verticalCenter
            width: 150
            height: Theme.islandHeight
            text: Media.label
            color: Theme.fg
            pixelSize: Theme.fontSizeSmall
            active: Media.playing
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                Media.toggle();
            else
                root.activated();
        }

        onWheel: wheel => {
            wheel.accepted = true;
            if (wheel.angleDelta.y > 0)
                Media.previous();
            else
                Media.next();
        }
    }
}
