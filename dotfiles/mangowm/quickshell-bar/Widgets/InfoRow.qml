import QtQuick
import "../Config"

// Fixed-width label with a free-flowing value, for the identity rows on the
// system page.
Item {
    id: root

    property string label: ""
    property string value: ""
    property color valueColor: Theme.fg

    implicitHeight: 17

    Text {
        id: name

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 52
        text: root.label
        color: Theme.fgFaint
        font.family: Theme.fontFamily
        renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall - 2
        font.weight: Font.DemiBold
        font.letterSpacing: 0.6
    }

    Text {
        anchors.left: name.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        text: root.value
        color: root.valueColor
        font.family: Theme.fontFamily
        renderType: Text.QtRendering
        font.pixelSize: Theme.fontSizeSmall - 1
    }
}
