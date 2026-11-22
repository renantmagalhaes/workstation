pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Config"

PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: DeadKeysManager.open

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-deadkeys"
    WlrLayershell.keyboardFocus: (DeadKeysManager.open && DeadKeysManager.activeMonitorName === monName) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string monName: win.screen?.name ?? "DP-1"
    readonly property bool isTargetMonitor: DeadKeysManager.activeMonitorName === monName

    // Click outside dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: DeadKeysManager.closePicker()
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        visible: win.isTargetMonitor
        width: grid.width + 2 * pad
        height: header.height + grid.height + hint.height + 2 * pad + 2 * spacing
        radius: Theme.panelRadius
        color: Theme.islandBg
        border.width: 1
        border.color: Theme.islandBorder

        readonly property int pad: 18
        readonly property int spacing: 12
        readonly property int cols: 6
        readonly property int tile: 64
        readonly property int gap: 8

        property int current: 0
        readonly property bool keyStage: DeadKeysManager.selectedKey === ""
        readonly property var items: keyStage ? DeadKeysManager.keys : DeadKeysManager.chars

        opacity: DeadKeysManager.open ? 1.0 : 0.0
        scale: DeadKeysManager.open ? 1.0 : 0.95
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        // Swallow clicks so the backdrop doesn't dismiss
        MouseArea { anchors.fill: parent }

        onItemsChanged: current = 0

        function move(dx, dy): void {
            const total = items.length;
            if (total === 0) return;
            current = Math.max(0, Math.min(total - 1, current + dx + dy * cols));
        }

        function activate(idx): void {
            if (idx < 0 || idx >= items.length) return;
            if (keyStage)
                DeadKeysManager.chooseKey(items[idx]);
            else
                DeadKeysManager.typeChar(items[idx]);
        }

        Connections {
            target: DeadKeysManager
            function onOpenChanged() {
                if (DeadKeysManager.open) {
                    card.current = 0;
                    Qt.callLater(() => keys.forceActiveFocus());
                }
            }
        }

        FocusScope {
            id: keys
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Escape:
                    DeadKeysManager.back(); break;
                case Qt.Key_Backspace:
                    if (!card.keyStage) DeadKeysManager.back(); break;
                case Qt.Key_Left: card.move(-1, 0); break;
                case Qt.Key_Right: card.move(1, 0); break;
                case Qt.Key_Up: card.move(0, -1); break;
                case Qt.Key_Down: card.move(0, 1); break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    card.activate(card.current); break;
                default:
                    if (card.keyStage) {
                        DeadKeysManager.chooseKey(event.text.toLowerCase());
                    } else if (event.text >= "1" && event.text <= "9") {
                        card.activate(parseInt(event.text) - 1);
                    }
                }
                event.accepted = true;
            }

            Column {
                anchors.centerIn: parent
                spacing: card.spacing

                Column {
                    id: header
                    spacing: 1

                    Text {
                        text: card.keyStage ? "DEAD KEYS" : "DEAD KEYS · " + DeadKeysManager.selectedKey.toUpperCase()
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                    }

                    Text {
                        text: card.keyStage ? "Pick a base letter" : "Pick a character to type"
                        color: Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Grid {
                    id: grid
                    width: card.cols * card.tile + (card.cols - 1) * card.gap
                    columns: card.cols
                    spacing: card.gap

                    Repeater {
                        model: card.items

                        Rectangle {
                            id: cell
                            required property int index
                            required property string modelData

                            width: card.tile
                            height: card.tile
                            radius: Theme.chipRadius + 3
                            color: index === card.current ? Theme.highlight : Theme.tint
                            border.width: index === card.current ? 1 : 0
                            border.color: Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: cell.modelData
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 26
                            }

                            // Quick-select number hint for the character stage
                            Text {
                                visible: !card.keyStage && cell.index < 9
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 5
                                text: cell.index + 1
                                color: Theme.fgFaint
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: card.current = cell.index
                                onClicked: card.activate(cell.index)
                            }
                        }
                    }
                }

                Text {
                    id: hint
                    text: card.keyStage ? "type a letter · ↵ select · esc close" : "1-9 or ↵ type · ⌫ back · esc back"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
            }
        }
    }
}
