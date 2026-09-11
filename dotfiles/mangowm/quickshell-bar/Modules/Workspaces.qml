import QtQuick
import "../Config"
import "../Services"

// Mango tag indicator. Dots for idle tags, a stretched pill for the focused
// one -- the same expand-on-select language as the island itself.
Item {
    id: root

    required property string monitorName

    readonly property var tags: Mango.tagsFor(monitorName)
    readonly property bool overview: Mango.inOverview(monitorName)

    implicitWidth: row.implicitWidth + Theme.capsulePadH
    implicitHeight: Theme.islandHeight

    function switchBy(step) {
        const current = tags.findIndex(t => t.is_active);
        if (current < 0) return;
        const next = Math.max(0, Math.min(Mango.visibleTags - 1, current + step));
        if (next !== current) Mango.focusTag(root.monitorName, next + 1);
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: Mango.visibleTags

            delegate: Item {
                id: slot

                required property int index

                readonly property var tag: root.tags[index] ?? null
                readonly property bool isActive: !root.overview && (tag?.is_active ?? false)
                readonly property bool occupied: (tag?.client_count ?? 0) > 0
                readonly property bool urgent: tag?.is_urgent ?? false

                width: dot.width
                height: Theme.islandHeight

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durNormal
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.3
                    }
                }

                Rectangle {
                    id: dot

                    anchors.verticalCenter: parent.verticalCenter
                    width: slot.isActive ? 22 : 8
                    height: 8
                    radius: height / 2
                    color: slot.urgent ? Theme.urgent : slot.isActive ? Theme.wsActive : slot.occupied ? Theme.wsOccupied : Theme.wsEmpty
                    opacity: hover.containsMouse && !slot.isActive ? 1 : 0.95
                    scale: hover.containsMouse && !slot.isActive ? 1.35 : 1

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.durNormal
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.3
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
