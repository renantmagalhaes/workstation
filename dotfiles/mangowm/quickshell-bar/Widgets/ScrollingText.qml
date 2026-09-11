import QtQuick
import "../Config"

// Marquee that only scrolls when the text actually overflows, pausing at each
// end. Driven by a Timer rather than a NumberAnimation: a running animation
// forces a repaint every vsync for the whole shell, which is a lot of GPU for
// a strip of text.
Item {
    id: root

    property string text: ""
    property color color: Theme.fg
    property int pixelSize: Theme.fontSize
    property int weight: Font.Medium
    property bool active: true

    readonly property bool overflowing: label.implicitWidth > width
    readonly property bool scrolling: overflowing && active && visible

    property real offset: 0
    property int direction: 1
    property int holdMs: 1600

    readonly property real maxOffset: Math.max(0, label.implicitWidth - width)

    implicitHeight: label.implicitHeight
    clip: true

    onTextChanged: {
        offset = 0;
        direction = 1;
        holdMs = 1600;
    }

    Text {
        id: label

        x: -Math.min(root.offset, root.maxOffset)
        width: root.overflowing ? implicitWidth : root.width
        anchors.verticalCenter: parent.verticalCenter

        text: root.text
        color: root.color
        font.family: Theme.fontFamily; renderType: Text.QtRendering
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        wrapMode: Text.NoWrap
        elide: root.overflowing ? Text.ElideNone : Text.ElideRight
    }

    Timer {
        interval: 40
        repeat: true
        running: root.scrolling

        onTriggered: {
            if (root.holdMs > 0) {
                root.holdMs -= interval;
                return;
            }

            const next = root.offset + root.direction * interval * 0.03;
            if (next >= root.maxOffset) {
                root.offset = root.maxOffset;
                root.direction = -1;
                root.holdMs = 1600;
            } else if (next <= 0) {
                root.offset = 0;
                root.direction = 1;
                root.holdMs = 1600;
            } else {
                root.offset = next;
            }
        }
    }
}
