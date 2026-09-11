import QtQuick
import Quickshell
import "../Config"

// Month grid, built by hand. QtQuick.Controls' Calendar pulls in a whole style
// and can't be themed to match, so a 42-cell array is both smaller and exact.
Item {
    id: root

    property date displayedMonth: new Date(clock.date.getFullYear(), clock.date.getMonth(), 1)

    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property var cells: buildCells()

    readonly property int cellWidth: (width - Theme.panelPad * 2) / 7
    readonly property int cellHeight: 42

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    function buildCells() {
        const year = displayedMonth.getFullYear();
        const month = displayedMonth.getMonth();

        // getDay() is Sunday-based; shift so the grid starts on Monday.
        const offset = (new Date(year, month, 1).getDay() + 6) % 7;

        const out = [];
        for (let i = 0; i < 42; i++) {
            const date = new Date(year, month, i - offset + 1);
            out.push({
                day: date.getDate(),
                inMonth: date.getMonth() === month,
                today: sameDay(date, clock.date)
            });
        }
        return out;
    }

    function shiftMonth(offset) {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + offset, 1);
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPad
        spacing: 6

        // ---- Header ---------------------------------------------------------
        Item {
            width: parent.width
            height: 30

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                text: Qt.formatDateTime(root.displayedMonth, "MMMM yyyy")
                color: Theme.fg
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.DemiBold
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 2

                Repeater {
                    model: [
                        {
                            glyph: "‹",
                            step: -1
                        },
                        {
                            glyph: "›",
                            step: 1
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width: 24
                        height: 24
                        radius: 12
                        color: navArea.containsMouse ? Theme.hover : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durSnappy
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            color: Theme.fgDim
                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSize + 2
                        }

                        MouseArea {
                            id: navArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shiftMonth(modelData.step)
                        }
                    }
                }
            }
        }

        // ---- Weekday labels --------------------------------------------------
        Row {
            Repeater {
                model: root.weekdays

                delegate: Text {
                    required property var modelData

                    width: root.cellWidth
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 1
                    font.weight: Font.DemiBold
                }
            }
        }

        // ---- Days ------------------------------------------------------------
        Grid {
            columns: 7

            Repeater {
                model: root.cells

                delegate: Item {
                    id: cell

                    required property var modelData

                    width: root.cellWidth
                    height: root.cellHeight

                    Rectangle {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        color: cell.modelData.today ? Theme.fg : dayArea.containsMouse ? Theme.hover : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durSnappy
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.modelData.day
                        color: cell.modelData.today ? "#000000" : cell.modelData.inMonth ? Theme.fg : Theme.fgFaint
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall + 1
                        font.weight: cell.modelData.today ? Font.Bold : Font.Medium
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            root.shiftMonth(wheel.angleDelta.y > 0 ? -1 : 1);
            wheel.accepted = true;
        }
    }
}
