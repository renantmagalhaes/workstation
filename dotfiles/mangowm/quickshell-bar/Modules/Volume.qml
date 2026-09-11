import QtQuick
import "../Config"
import "../Services"

Item {
    id: root

    property bool active: false
    signal activated

    // Touchpads emit many small deltas; accumulate them so a gentle two-finger
    // swipe doesn't slam the volume from 0 to 100.
    property real wheelAccumulator: 0

    implicitWidth: row.implicitWidth + Theme.capsulePadH * 2
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

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.icon
            color: Audio.muted ? Theme.urgent : Theme.fg
            font.family: Theme.iconFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durSnappy
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.muted ? "off" : Audio.percent + "%"
            color: Audio.muted ? Theme.fgDim : Theme.fg
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                Audio.toggleMute();
            else
                root.activated();
        }

        onWheel: wheel => {
            wheel.accepted = true;

            const delta = wheel.angleDelta.y;
            const isMouseWheel = Math.abs(delta) >= 120 && Math.abs(delta) % 120 === 0;

            if (isMouseWheel) {
                Audio.step(delta > 0 ? 0.05 : -0.05);
                return;
            }

            root.wheelAccumulator += delta;
            if (Math.abs(root.wheelAccumulator) < 120) return;
            Audio.step(root.wheelAccumulator > 0 ? 0.02 : -0.02);
            root.wheelAccumulator = 0;
        }
    }
}
