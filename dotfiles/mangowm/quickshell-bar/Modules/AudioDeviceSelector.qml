import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

// Collapsed: a single row naming the device in use. Expanded: the full list.
// Most of the time you only want to see what you are playing through, not
// every card the machine owns.
Item {
    id: root

    property string title: ""
    property var devices: []
    property var current: null
    property bool expanded: false

    signal toggleRequested
    signal selected(var node)

    readonly property string currentName: current ? Audio.displayName(current) : "No device"

    implicitHeight: header.height + (expanded ? list.implicitHeight + 4 : 0)
    clip: true

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.durNormal
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: header

        width: parent.width
        height: 28

        Rectangle {
            anchors.fill: parent
            radius: Theme.chipRadius
            color: root.expanded ? Theme.pressed : area.containsMouse ? Theme.hover : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durSnappy
                }
            }
        }

        Text {
            id: chevron

            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅀"
            color: Theme.fgDim
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            rotation: root.expanded ? 0 : -90

            Behavior on rotation {
                NumberAnimation {
                    duration: Theme.durNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            anchors.left: chevron.right
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: root.currentName
            color: Theme.fg
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }

        MouseArea {
            id: area

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleRequested()
        }
    }

    Column {
        id: list

        y: header.height + 4
        width: parent.width
        spacing: 2
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSnappy
            }
        }

        Repeater {
            model: root.devices

            delegate: DeviceRow {
                required property var modelData

                width: list.width
                label: Audio.displayName(modelData)
                selected: modelData === root.current
                onActivated: root.selected(modelData)
            }
        }
    }
}
