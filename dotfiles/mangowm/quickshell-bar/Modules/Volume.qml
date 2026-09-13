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

    // Above the chip-wide handler below it, so the microphone's own right-click
    // target gets first refusal on the event. Later siblings stack on top, so
    // this ordering is load-bearing: with the content declared first the
    // chip-wide area would swallow every click before the meter saw it.
    Row {
        id: row

        z: 1
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

        // A little extra air so output and input read as two groups inside one
        // chip rather than as one run of glyphs.
        Item {
            width: 2
            height: 1
        }

        // Input. Its own click target: right-clicking here mutes the
        // microphone, while right-clicking anywhere else in the chip still
        // mutes the output.
        Item {
            id: micGroup

            anchors.verticalCenter: parent.verticalCenter
            visible: Audio.hasSource
            implicitWidth: micRow.implicitWidth
            implicitHeight: Theme.islandHeight

            Row {
                id: micRow

                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Audio.micIcon
                    color: Audio.micMuted ? Theme.urgent : Theme.fg
                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.iconSize

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durSnappy
                        }
                    }
                }

                // Track plus fill, so the meter still marks its own place when
                // the microphone is silent or muted.
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 13
                    radius: width / 2
                    color: Theme.tint

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        radius: parent.radius
                        height: Audio.micMuted ? 0 : Math.max(2, Math.round(parent.height * Audio.micLevel))
                        color: Theme.accent

                        // Short enough to still feel live at the meter's 20Hz
                        // update rate, long enough to not read as jitter.
                        Behavior on height {
                            NumberAnimation {
                                duration: 70
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }

            // Left clicks are left unaccepted so they fall through to the
            // chip's own handler and still open the volume page.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: Audio.toggleMicMute()
                // Let the scroll reach the chip's handler so the wheel still
                // adjusts output volume across the whole module.
                onWheel: wheel => wheel.accepted = false
            }
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
