import QtQuick
import "../Config"

// Three bars that rise and fall while audio is playing, and sit flat when it is
// not.
//
// Monochrome on purpose: it belongs to the bar's glyph-and-text language, so it
// frames the album art beside it rather than competing with it the way a second
// coloured element would.
Item {
    id: root

    property bool active: false
    property color color: Theme.fg

    property int barWidth: 3
    property int barSpacing: 2
    property int maxHeight: 13
    property int idleHeight: 3

    // Deliberately mismatched periods, and none of them a multiple of another,
    // so the bars drift out of phase indefinitely and read as a level meter
    // rather than a blinking ornament. Taller in the middle, the way a spectrum
    // display sits, so it has a shape even at a glance.
    readonly property var bars: [
        {
            lo: 0.10,
            hi: 0.62,
            duration: 530
        },
        {
            lo: 0.22,
            hi: 0.88,
            duration: 370
        },
        {
            lo: 0.15,
            hi: 1.0,
            duration: 450
        },
        {
            lo: 0.05,
            hi: 0.80,
            duration: 610
        },
        {
            lo: 0.28,
            hi: 0.70,
            duration: 410
        }
    ]

    implicitWidth: barWidth * bars.length + barSpacing * (bars.length - 1)
    implicitHeight: maxHeight

    Row {
        anchors.fill: parent
        spacing: root.barSpacing

        Repeater {
            model: root.bars

            delegate: Rectangle {
                required property var modelData

                property real amp: 0.2

                anchors.bottom: parent.bottom
                width: root.barWidth
                radius: root.barWidth / 2
                color: root.color

                // Height is a binding rather than the animated property: an
                // animation that is simply stopped leaves its target wherever
                // it happened to be, so the bars would freeze mid-bounce
                // instead of settling flat when playback pauses.
                height: root.active ? Math.round(root.idleHeight + (root.maxHeight - root.idleHeight) * amp) : root.idleHeight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durSnappy
                    }
                }

                SequentialAnimation on amp {
                    running: root.active
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: modelData.hi
                        duration: modelData.duration
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: modelData.lo
                        duration: modelData.duration
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
