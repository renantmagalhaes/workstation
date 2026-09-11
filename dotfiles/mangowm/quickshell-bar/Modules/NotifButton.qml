import QtQuick
import "../Config"
import "../Services"

// Left-click restores the last dismissed notification (what waybar's
// custom/notification did), right-click toggles do-not-disturb, middle-click
// dismisses everything.
Item {
    id: root

    implicitWidth: Theme.islandHeight - 6
    implicitHeight: Theme.islandHeight

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

    Text {
        id: bell

        anchors.centerIn: parent
        text: Notifs.icon
        color: Notifs.dnd ? Theme.fgFaint : Theme.fg
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Rectangle {
        anchors.right: bell.right
        anchors.top: bell.top
        anchors.rightMargin: -4
        anchors.topMargin: -2
        width: Math.max(12, badge.implicitWidth + 5)
        height: 12
        radius: 6
        color: Theme.urgent
        visible: Notifs.count > 0

        Text {
            id: badge

            anchors.centerIn: parent
            text: Notifs.count > 9 ? "9+" : Notifs.count
            color: "#FFFFFF"
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: 8
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                Notifs.toggleDnd();
            else if (event.button === Qt.MiddleButton)
                Notifs.dismissAll();
            else
                Notifs.restore();
        }
    }
}
