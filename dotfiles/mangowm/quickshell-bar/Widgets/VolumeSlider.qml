import QtQuick
import "../Config"

// Icon button + draggable track, shared by the output and input rows.
Item {
    id: root

    property real value: 0
    property bool muted: false
    property string icon: ""
    property string readout: ""

    signal requested(real value)
    signal muteToggled

    implicitHeight: 30

    Rectangle {
        id: muteButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: Theme.chipRadius
        color: muteArea.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.muted ? Theme.urgent : Theme.fg
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize
        }

        MouseArea {
            id: muteArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.muteToggled()
        }
    }

    Text {
        id: readoutLabel

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        width: 44
        text: root.readout
        color: root.muted ? Theme.fgFaint : Theme.fg
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Item {
        id: slider

        anchors.left: muteButton.right
        anchors.right: readoutLabel.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 28

        function applyFromX(x) {
            root.requested(Math.max(0, Math.min(1, x / width)));
        }

        Rectangle {
            id: track

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 5
            radius: 2.5
            color: Theme.wsEmpty

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: parent.radius
                color: root.muted ? Theme.fgFaint : Theme.fg

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durSnappy
                    }
                }
            }
        }

        Rectangle {
            x: track.width * Math.max(0, Math.min(1, root.value)) - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            radius: 6.5
            color: Theme.fg
            scale: sliderArea.containsMouse || sliderArea.pressed ? 1.2 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.durSnappy
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: sliderArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed: event => slider.applyFromX(event.x)
            onPositionChanged: event => {
                if (pressed) slider.applyFromX(event.x);
            }
            onWheel: wheel => {
                wheel.accepted = true;
                root.requested(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))));
            }
        }
    }
}
