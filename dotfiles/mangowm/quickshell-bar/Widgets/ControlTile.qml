import QtQuick
import "../Config"

// A quick-toggle tile with two hit zones: the icon square flips the thing on or
// off, the rest of the tile opens its detail list. When there is no detail list
// the whole tile just toggles.
Item {
    id: root

    property string title: ""
    property string detail: ""
    property string glyph: ""
    property bool checked: false
    property bool available: true
    property bool expandable: false
    property bool expanded: false

    signal toggled
    signal activated

    implicitHeight: 46
    opacity: available ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: Theme.chipRadius + 2
        color: root.expanded ? Theme.pressed : area.containsMouse ? Theme.hover : "#14FFFFFF"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Rectangle {
        id: iconZone

        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: Theme.chipRadius
        color: root.checked ? Theme.fg : "#1AFFFFFF"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.glyph
            color: root.checked ? "#000000" : Theme.fgDim
            font.family: Theme.iconFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durSnappy
                }
            }
        }
    }

    Column {
        anchors.left: iconZone.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.title
            color: Theme.fg
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.detail
            color: Theme.fgFaint
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall - 2
            visible: text !== ""
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        enabled: root.available
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
            // The icon square is the on/off switch; everywhere else opens the
            // list. Without a list, any click toggles.
            const onIcon = event.x >= iconZone.x && event.x <= iconZone.x + iconZone.width;
            if (!root.expandable || onIcon) root.toggled();
            else root.activated();
        }
    }
}
