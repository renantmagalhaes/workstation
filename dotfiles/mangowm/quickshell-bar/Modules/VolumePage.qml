import QtQuick
import "../Config"
import "../Services"

Item {
    id: root

    readonly property string deviceName: Audio.sink?.nickname || Audio.sink?.description || Audio.sink?.name || "No output"

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPad
        spacing: 10

        Item {
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 46
                elide: Text.ElideRight
                text: root.deviceName
                color: Theme.fgDim
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Audio.muted ? "muted" : Audio.percent + "%"
                color: Audio.muted ? Theme.urgent : Theme.fg
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Rectangle {
                id: muteButton

                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 30
                radius: 15
                color: muteArea.containsMouse ? Theme.hover : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durSnappy
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Audio.icon
                    color: Audio.muted ? Theme.urgent : Theme.fg
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.iconSize
                }

                MouseArea {
                    id: muteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMute()
                }
            }

            Item {
                id: slider

                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - muteButton.width - parent.spacing
                height: 28

                function applyFromX(x) {
                    Audio.setVolume(Math.max(0, Math.min(1, x / width)));
                }

                Rectangle {
                    id: track

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.wsEmpty

                    Rectangle {
                        width: parent.width * Audio.volume
                        height: parent.height
                        radius: parent.radius
                        color: Audio.muted ? Theme.fgFaint : Theme.fg

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durSnappy
                            }
                        }
                    }
                }

                Rectangle {
                    id: knob

                    x: track.width * Audio.volume - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
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
                        Audio.step(wheel.angleDelta.y > 0 ? 0.05 : -0.05);
                        wheel.accepted = true;
                    }
                }
            }
        }
    }
}
