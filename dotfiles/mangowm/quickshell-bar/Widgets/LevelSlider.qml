import QtQuick
import "../Config"

// Draggable 0..1 track with an optimistic preview.
//
// The value we write goes out to PipeWire and comes back asynchronously, so
// binding the knob straight to the authoritative value makes it snap backwards
// mid-drag. Instead the knob follows a local preview while dragging, and keeps
// following it for a moment after release until the real value catches up (or a
// timeout gives up waiting).
Item {
    id: root

    property real value: 0
    property bool muted: false
    property color fillColor: Theme.fg
    property real wheelStep: 0.05

    signal requested(real value)

    property real preview: value
    property bool dragging: false
    property bool awaiting: false

    readonly property real shown: dragging || awaiting ? preview : Math.max(0, Math.min(1, value))

    implicitHeight: 22

    onValueChanged: {
        if (!dragging && awaiting && Math.abs(value - preview) <= 0.02) {
            awaiting = false;
            confirmTimeout.stop();
        }
        if (!dragging && !awaiting) preview = value;
    }

    Timer {
        id: confirmTimeout
        interval: 700
        onTriggered: root.awaiting = false
    }

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    function applyFromX(x) {
        preview = clamp(x / Math.max(1, width));
    }

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 5
        radius: 2.5
        color: Theme.wsEmpty

        Rectangle {
            width: parent.width * root.shown
            height: parent.height
            radius: parent.radius
            color: root.muted ? Theme.fgFaint : root.fillColor

            // No easing while dragging -- the knob must track the pointer.
            Behavior on width {
                enabled: !root.dragging
                NumberAnimation {
                    duration: Theme.durSnappy
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.durSnappy
                }
            }
        }
    }

    Rectangle {
        x: track.width * root.shown - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: 13
        height: 13
        radius: 6.5
        color: root.muted ? Theme.fgFaint : Theme.fg
        scale: area.containsMouse || area.pressed ? 1.2 : 1

        Behavior on x {
            enabled: !root.dragging
            NumberAnimation {
                duration: Theme.durSnappy
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.durSnappy
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: event => {
            confirmTimeout.stop();
            root.awaiting = false;
            root.dragging = true;
            root.applyFromX(event.x);
        }
        onPositionChanged: event => {
            if (pressed) root.applyFromX(event.x);
        }
        onReleased: event => {
            root.applyFromX(event.x);
            root.dragging = false;
            root.awaiting = true;
            confirmTimeout.restart();
            root.requested(root.preview);
        }
        onCanceled: {
            confirmTimeout.stop();
            root.dragging = false;
            root.awaiting = false;
            root.preview = root.value;
        }
        onWheel: wheel => {
            wheel.accepted = true;
            root.requested(root.clamp(root.shown + (wheel.angleDelta.y > 0 ? root.wheelStep : -root.wheelStep)));
        }
    }
}
