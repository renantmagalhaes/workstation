import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

// Appears only in mango's horizontal scroller layout, when the active tag holds
// more windows than fit on screen -- otherwise there is nothing on the bar to
// tell you windows exist off to the side. Clicking walks the stack.
Item {
    id: root

    required property string monitorName

    readonly property bool present: Mango.scrollableOn(monitorName)

    implicitWidth: present ? row.implicitWidth + 4 : 0
    implicitHeight: Theme.islandHeight
    visible: present

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durIsland
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 0

        IconButton {
            glyph: "󰁍"
            size: 22
            glyphSize: Theme.fontSizeSmall + 1
            onActivated: Mango.focusPrev()
        }

        IconButton {
            glyph: "󰁔"
            size: 22
            glyphSize: Theme.fontSizeSmall + 1
            onActivated: Mango.focusNext()
        }
    }

    // A slow breathe, so off-screen windows register peripherally without the
    // hard blink the waybar version used.
    SequentialAnimation {
        running: root.present
        loops: Animation.Infinite
        onStopped: row.opacity = 1

        NumberAnimation {
            target: row
            property: "opacity"
            from: 1.0
            to: 0.45
            duration: 900
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: row
            property: "opacity"
            from: 0.45
            to: 1.0
            duration: 900
            easing.type: Easing.InOutSine
        }
    }

    // Scrolling over the arrows walks the stack too.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            wheel.accepted = true;
            if (wheel.angleDelta.y > 0)
                Mango.focusPrev();
            else
                Mango.focusNext();
        }
    }
}
