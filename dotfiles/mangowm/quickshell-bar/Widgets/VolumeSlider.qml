import QtQuick
import "../Config"

// Icon button + level track + readout, shared by the output, input and per-app
// rows on the audio page.
Item {
    id: root

    property real value: 0
    property bool muted: false
    property string icon: ""
    property string readout: ""
    // Optional leading label used instead of a glyph (per-app rows).
    property string label: ""

    signal requested(real value)
    signal muteToggled

    implicitHeight: 30

    Rectangle {
        id: muteButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.label !== "" ? 96 : 30
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
            visible: root.label === ""
            text: root.icon
            color: root.muted ? Theme.urgent : Theme.fg
            font.family: Theme.iconFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            elide: Text.ElideRight
            text: root.label
            color: root.muted ? Theme.fgFaint : Theme.fgDim
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
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
        font.family: Theme.fontFamily
        renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    LevelSlider {
        anchors.left: muteButton.right
        anchors.right: readoutLabel.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        value: root.value
        muted: root.muted
        onRequested: v => root.requested(v)
    }
}
