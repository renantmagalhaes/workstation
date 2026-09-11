import QtQuick
import "../Config"

// Small square glyph button used for window actions, media transport and
// session entries.
Item {
    id: root

    property string glyph: ""
    property color accent: Theme.fg
    property color idleColor: Theme.fgDim
    property real size: Theme.islandHeight - 10
    property real glyphSize: Theme.iconSize
    property bool enabled: true

    signal activated

    implicitWidth: size
    implicitHeight: size
    opacity: enabled ? 1 : 0.35

    Rectangle {
        anchors.fill: parent
        radius: Theme.chipRadius
        color: area.containsMouse && root.enabled ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: area.containsMouse && root.enabled ? root.accent : root.idleColor
        font.family: Theme.iconFamily; renderType: Text.QtRendering
        font.pixelSize: root.glyphSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
