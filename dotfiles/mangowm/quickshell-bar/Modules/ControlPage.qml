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

    // "" | "network" | "bluetooth"
    property string section: "network"

    readonly property real tileWidth: (width - Theme.panelPad * 2 - 6) / 2

    implicitHeight: column.implicitHeight + Theme.panelPad * 2

    function open(name) {
        section = section === name ? "" : name;
        // Only scan while the network list is actually visible.
        if (section === "network" && Control.wifiDevice !== "") {
            Control.scanWifi();
        }
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
                expandable: Control.wifiDevice !== "" || Control.ethDevice !== ""
                expanded: root.section === "network"
                onToggled: {
                    if (Control.ethConnected) {
                        Control.toggleEth();
                    } else if (Control.wifiDevice !== "") {
                        Control.toggleWifi();
                    } else if (Control.ethDevice !== "") {
                        Control.toggleEth();
                    }
                }
                onActivated: root.open("network")
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

            ControlTile {
                width: root.tileWidth
                title: "Audio Out"
                detail: Audio.muted ? "muted" : `${Audio.percent}%`
                glyph: Audio.icon
                checked: !Audio.muted
                onToggled: Audio.toggleMute()
            }

            ControlTile {
                width: root.tileWidth
                title: "Microphone"
                detail: Audio.micMuted ? "muted" : `${Audio.micPercent}%`
                glyph: Audio.micIcon
                checked: !Audio.micMuted
                onToggled: Audio.toggleMicMute()
            }
        }

        // =====================================================================
        // SECTION: NETWORK (INTERNAL CABLE ADAPTER + WI-FI)
        // =====================================================================
        Column {
            width: parent.width
            spacing: 6
            visible: root.section === "network"

            // Section label: Wired / Cable Adapter
            Text {
                text: "INTERNAL CABLE ADAPTER"
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 2
                font.weight: Font.DemiBold
                font.letterSpacing: 1
                visible: Control.ethDevice !== ""
            }

            // Wired Adapter Card
            EthernetCard {
                width: parent.width
                visible: Control.ethDevice !== ""
            }

            // Section label: Wi-Fi Networks with toggle
            Row {
                width: parent.width
                visible: Control.wifiDevice !== ""

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "WI-FI NETWORKS"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                Item {
                    width: parent.width - 120 - wifiTogglePill.width
                    height: 1
                }

                Rectangle {
                    id: wifiTogglePill
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    width: wifiToggleText.implicitWidth + 14
                    radius: 10
                    color: wifiToggleMouse.containsMouse ? Theme.hover : (Control.wifiRadio ? Theme.pressed : Theme.tint)
                    border.width: 1
                    border.color: Control.wifiRadio ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Theme.islandBorder

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Text {
                        id: wifiToggleText
                        anchors.centerIn: parent
                        text: Control.wifiRadio ? "Wi-Fi On" : "Wi-Fi Off"
                        color: Control.wifiRadio ? Theme.accent : Theme.fgDim
                        font.family: Theme.fontFamily
                        renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: wifiToggleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Control.toggleWifi()
                    }
                }
            }

            // Wi-Fi network list
            Column {
                width: parent.width
                spacing: 2
                visible: Control.wifiDevice !== "" && Control.wifiRadio && Control.wifiNetworks.length > 0

                Repeater {
                    model: Control.wifiNetworks

                    delegate: DeviceRow {
                        required property var modelData

                        width: parent.width
                        label: `${modelData.ssid}${modelData.security ? "  ·  " + modelData.security : ""}`
                        selected: modelData.active === true
                        onActivated: Control.connectWifi(modelData.ssid)
                    }
                }
            }

            Text {
                width: parent.width
                visible: Control.wifiDevice !== "" && (!Control.wifiRadio || Control.wifiNetworks.length === 0)
                text: !Control.wifiRadio ? "Wi-Fi radio is turned off" : (Control.scanning ? "Scanning for networks…" : "No Wi-Fi networks found")
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 1
            }
        }

        // =====================================================================
        // SECTION: BLUETOOTH
        // =====================================================================
        Column {
            width: parent.width
            spacing: 6
            visible: root.section === "bluetooth"

            Row {
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "BLUETOOTH DEVICES"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                Item {
                    width: parent.width - 150 - btTogglePill.width
                    height: 1
                }

                Rectangle {
                    id: btTogglePill
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    width: btToggleText.implicitWidth + 14
                    radius: 10
                    color: btToggleMouse.containsMouse ? Theme.hover : (Control.btPowered ? Theme.pressed : Theme.tint)
                    border.width: 1
                    border.color: Control.btPowered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Theme.islandBorder

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Text {
                        id: btToggleText
                        anchors.centerIn: parent
                        text: Control.btPowered ? "Bluetooth On" : "Bluetooth Off"
                        color: Control.btPowered ? Theme.accent : Theme.fgDim
                        font.family: Theme.fontFamily
                        renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: btToggleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Control.toggleBt()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 2
                visible: Control.btDevices.length > 0

                Repeater {
                    model: Control.btDevices

                    delegate: DeviceRow {
                        required property var modelData

                        width: parent.width
                        label: modelData.name
                        selected: modelData.connected === true
                        onActivated: Control.toggleBtDevice(modelData)
                    }
                }
            }

            Text {
                width: parent.width
                visible: Control.btDevices.length === 0
                text: Control.btPowered ? "No paired devices" : "Bluetooth is turned off"
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 1
            }
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
                    color: segment.current ? Theme.pressed : segmentArea.containsMouse ? Theme.hover : Theme.tint

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

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.5
        }

        ThemePicker {
            width: parent.width
        }
    }
}
