import QtQuick
import "../Config"

// One selectable audio device.
Item {
    id: root

    property string label: ""
    property bool selected: false

    signal activated

    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.chipRadius
        color: root.selected ? Theme.pressed : area.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Text {
        id: mark

        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.selected ? "󰄬" : "󰧞"
        color: root.selected ? Theme.good : Theme.fgFaint
        font.family: Theme.iconFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        anchors.left: mark.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        text: root.label
        color: root.selected ? Theme.fg : Theme.fgDim
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
        font.weight: root.selected ? Font.DemiBold : Font.Normal
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
