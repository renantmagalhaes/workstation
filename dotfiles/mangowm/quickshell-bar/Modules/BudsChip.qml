import QtQuick
import "../Config"
import "../Services"

// Low-bud warning. Stays collapsed to zero width until a bud drops under 10%,
// so the island only grows when there is something you actually need to act on
// -- the full reading lives in SystemPage and in the Extra Options menu.
//
// It names the side rather than showing a single number: the buds discharge
// independently (one can sit in the case while the other is worn), so "R 8%"
// tells you which one to swap out and a combined figure does not.
Item {
    id: root

    readonly property bool present: InzoneBuds.low

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
        color: mouse.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 5

        Text {
            id: glyph

            anchors.verticalCenter: parent.verticalCenter
            text: "󰋋"
            color: Theme.urgent
            font.family: Theme.iconFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize

            // Only runs while the chip is on screen, so it costs nothing the
            // rest of the time.
            SequentialAnimation on opacity {
                running: root.present
                loops: Animation.Infinite
                alwaysRunToEnd: true

                NumberAnimation {
                    to: 0.35
                    duration: 900
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 1.0
                    duration: 900
                    easing.type: Easing.InOutSine
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: InzoneBuds.lowLabel
            color: Theme.urgent
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: InzoneBuds.notifyLevels()
    }
}
