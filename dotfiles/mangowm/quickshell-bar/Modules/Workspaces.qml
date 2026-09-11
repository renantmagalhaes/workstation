import QtQuick
import "../Config"
import "../Services"

// Mango tag indicator: fixed-pitch dots with one pill that slides to the active
// tag.
//
// The slots are a constant width on purpose. Sizing them from their dot made
// every tag switch resize this module, which resized the row, which resized the
// pill -- and since the pill animates over a longer duration than the row, the
// row briefly grew wider than its own container and got clipped. Keeping the
// footprint fixed means switching tags moves one element and disturbs nothing
// else in the bar.
Item {
    id: root

    required property string monitorName

    readonly property var tags: Mango.tagsFor(monitorName)
    readonly property bool overview: Mango.inOverview(monitorName)

    readonly property int slotWidth: 12
    readonly property int slotSpacing: 6
    readonly property int dotSize: 8
    readonly property int pillWidth: 18

    readonly property int activeIndex: {
        if (overview) return -1;
        for (let i = 0; i < Mango.visibleTags; i++)
            if (root.tags[i]?.is_active) return i;
        return -1;
    }

    readonly property bool activeUrgent: activeIndex >= 0 ? (tags[activeIndex]?.is_urgent ?? false) : false

    // Room for the pill to overhang the first and last slot without touching
    // the island's own padding.
    implicitWidth: row.implicitWidth + 14
    implicitHeight: Theme.islandHeight

    function switchBy(step) {
        if (activeIndex < 0) return;
        const next = Math.max(0, Math.min(Mango.visibleTags - 1, activeIndex + step));
        if (next !== activeIndex) Mango.focusTag(root.monitorName, next + 1);
    }

    // The active indicator. One element animating x, rather than two dots
    // fighting over width, so the motion reads as a single slide.
    Rectangle {
        readonly property real slotCentre: row.x + Math.max(0, root.activeIndex) * (root.slotWidth + root.slotSpacing) + root.slotWidth / 2

        x: slotCentre - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: root.pillWidth
        height: root.dotSize
        radius: height / 2
        color: root.activeUrgent ? Theme.urgent : Theme.wsActive
        opacity: root.activeIndex >= 0 ? 1 : 0

        Behavior on x {
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSnappy
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.slotSpacing

        Repeater {
            model: Mango.visibleTags

            delegate: Item {
                id: slot

                required property int index

                readonly property var tag: root.tags[index] ?? null
                readonly property bool isActive: root.activeIndex === index
                readonly property bool occupied: (tag?.client_count ?? 0) > 0
                readonly property bool urgent: tag?.is_urgent ?? false

                width: root.slotWidth
                height: Theme.islandHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: root.dotSize
                    height: root.dotSize
                    radius: height / 2
                    color: slot.urgent ? Theme.urgent : slot.occupied ? Theme.wsOccupied : Theme.wsEmpty

                    // Hidden under the sliding pill, and fading back in as it
                    // leaves.
                    opacity: slot.isActive ? 0 : 1
                    scale: hover.containsMouse && !slot.isActive ? 1.25 : 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.durSnappy
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durSnappy
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
                    id: hover

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Mango.focusTag(root.monitorName, slot.index + 1)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            root.switchBy(wheel.angleDelta.y > 0 ? -1 : 1);
            wheel.accepted = true;
        }
    }
}
