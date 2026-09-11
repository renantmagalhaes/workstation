import QtQuick
import "../Config"

// Label + proportional bar + value, used for the load/memory/disk readouts.
Item {
    id: root

    property string label: ""
    property real ratio: 0
    property string value: ""
    property color barColor: Theme.fg

    implicitHeight: 26

    Text {
        id: name

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 56
        text: root.label
        color: Theme.fgDim
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Text {
        id: readout

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        width: 86
        text: root.value
        color: Theme.fg
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Rectangle {
        anchors.left: name.right
        anchors.right: readout.left
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: 5
        radius: 2.5
        color: Theme.wsEmpty

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.ratio))
            height: parent.height
            radius: parent.radius
            color: root.barColor

            Behavior on width {
                NumberAnimation {
                    duration: Theme.durNormal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.durNormal
                }
            }
        }
    }
}
