import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

// Quick toggles plus one shared detail list.
//
// Only one list is open at a time and both WiFi and Bluetooth render through
// the same DeviceRow, so adding a third device type later costs a case
// statement rather than another list implementation.
Item {
    id: root

    // "" | "wifi" | "bluetooth"
    property string section: ""

    readonly property real tileWidth: (width - Theme.panelPad * 2 - 6) / 2

    implicitHeight: column.implicitHeight + Theme.panelPad * 2

    function open(name) {
        section = section === name ? "" : name;
        // Only scan while the list is actually visible.
        if (section === "wifi") Control.scanWifi();
    }

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.panelPad
        }
        spacing: 6

        Grid {
            columns: 2
            columnSpacing: 6
            rowSpacing: 6

            ControlTile {
                width: root.tileWidth
                title: "Network"
                detail: Control.networkSummary
                glyph: Control.ethConnected ? "󰈁" : Control.wifiConnected ? "󰖩" : Control.wifiRadio ? "󰖪" : "󰖪"
                checked: Control.ethConnected || Control.wifiConnected
                expandable: Control.wifiDevice !== ""
                expanded: root.section === "wifi"
                onToggled: Control.toggleWifi()
                onActivated: root.open("wifi")
            }

            ControlTile {
                width: root.tileWidth
                title: "Bluetooth"
                detail: Control.btSummary
                glyph: Control.btPowered ? "󰂯" : "󰂲"
                checked: Control.btPowered
                expandable: true
                expanded: root.section === "bluetooth"
                onToggled: Control.toggleBt()
                onActivated: root.open("bluetooth")
            }

            ControlTile {
                width: root.tileWidth
                title: "Do not disturb"
                detail: Control.dnd ? "silenced" : "notifying"
                glyph: Control.dnd ? "󰂛" : "󰂚"
                checked: Control.dnd
                onToggled: Control.toggleDnd()
            }

            ControlTile {
                width: root.tileWidth
                title: "Keep awake"
                detail: Control.keepAwake ? "idle blocked" : "idle allowed"
                glyph: "󰅶"
                checked: Control.keepAwake
                onToggled: Control.toggleKeepAwake()
            }
        }

        // ---- Shared detail list ----------------------------------------------
        Column {
            width: parent.width
            spacing: 2
            visible: root.section !== "" && repeater.count > 0

            Repeater {
                id: repeater

                model: root.section === "bluetooth" ? Control.btDevices : root.section === "wifi" ? Control.wifiNetworks : []

                delegate: DeviceRow {
                    required property var modelData

                    width: parent.width
                    label: root.section === "bluetooth" ? modelData.name : `${modelData.ssid}${modelData.security ? "  ·  " + modelData.security : ""}`
                    selected: root.section === "bluetooth" ? modelData.connected === true : modelData.active === true
                    onActivated: {
                        if (root.section === "bluetooth") Control.toggleBtDevice(modelData);
                        else Control.connectWifi(modelData.ssid);
                    }
                }
            }
        }

        Text {
            width: parent.width
            visible: root.section !== "" && repeater.count === 0
            text: root.section === "wifi" ? (Control.scanning ? "Scanning…" : "No networks found") : "No paired devices"
            color: Theme.fgFaint
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall - 1
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.5
        }

        // ---- Power profile ----------------------------------------------------
        Row {
            width: parent.width
            spacing: 4

            Repeater {
                model: Control.profiles

                delegate: Rectangle {
                    id: segment

                    required property var modelData

                    readonly property bool current: Control.profile === modelData

                    width: (root.width - Theme.panelPad * 2 - 8) / 3
                    height: 24
                    radius: Theme.chipRadius
                    color: segment.current ? Theme.pressed : segmentArea.containsMouse ? Theme.hover : "#14FFFFFF"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durSnappy
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData === "power-saver" ? "saver" : modelData
                        color: segment.current ? Theme.fg : Theme.fgDim
                        font.family: Theme.fontFamily
                        renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                        font.weight: segment.current ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        id: segmentArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Control.act(["profile", segment.modelData])
                    }
                }
            }
        }
    }
}
