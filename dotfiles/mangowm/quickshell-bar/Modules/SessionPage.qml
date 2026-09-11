import QtQuick
import "../Config"
import "../Services"

// Replaces wlogout. Destructive actions arm on first click and fire on the
// second, so a stray click can never power the machine off.
Item {
    id: root

    property string armed: ""

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armed = ""
    }

    function trigger(action) {
        if (action.confirm && root.armed !== action.id) {
            root.armed = action.id;
            disarm.restart();
            return;
        }
        root.armed = "";
        disarm.stop();
        Session.run(action);
    }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: Session.actions

            delegate: Item {
                id: cell

                required property var modelData

                readonly property bool isArmed: root.armed === modelData.id

                width: 62
                height: 62

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: cell.isArmed ? (cell.modelData.destructive ? Theme.urgent : Theme.pressed) : area.containsMouse ? Theme.hover : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durSnappy
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cell.modelData.icon
                        color: cell.isArmed ? "#FFFFFF" : cell.modelData.destructive && area.containsMouse ? Theme.urgent : Theme.fg
                        font.family: Theme.iconFamily; renderType: Text.QtRendering
                        font.pixelSize: 20
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cell.isArmed ? "Confirm?" : cell.modelData.label
                        color: cell.isArmed ? "#FFFFFF" : Theme.fgDim
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.trigger(cell.modelData)
                }
            }
        }
    }
}
