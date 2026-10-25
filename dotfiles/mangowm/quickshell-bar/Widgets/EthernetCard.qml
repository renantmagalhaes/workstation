import QtQuick
import "../Config"
import "../Services"

// Detailed card for the physical / internal cable adapter (Ethernet).
// Displays hardware model, link state, speed, IP/gateway, MAC address,
// and provides one-click connect/disconnect and click-to-copy for IP.
Rectangle {
    id: root

    property bool ipCopied: false

    width: parent.width
    implicitHeight: mainCol.implicitHeight + 20
    radius: Theme.chipRadius + 2
    color: Theme.tint
    border.width: 1
    border.color: Control.ethConnected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : Theme.islandBorder

    Timer {
        id: copiedTimer
        interval: 1800
        onTriggered: root.ipCopied = false
    }

    Column {
        id: mainCol

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        spacing: 8

        // ---- Top row: Icon, Adapter Name/Device, and Action Button ---------
        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: 32
                height: 32
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                color: Control.ethConnected ? Qt.rgba(Theme.good.r, Theme.good.g, Theme.good.b, 0.18)
                     : Control.ethCarrier ? Qt.rgba(Theme.warn.r, Theme.warn.g, Theme.warn.b, 0.18)
                     : Qt.rgba(1, 1, 1, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: Control.ethConnected ? "󰈁" : Control.ethCarrier ? "󰈀" : "󰈂"
                    color: Control.ethConnected ? Theme.good : Control.ethCarrier ? Theme.warn : Theme.fgDim
                    font.family: Theme.iconFamily
                    renderType: Text.QtRendering
                    font.pixelSize: 17
                }
            }

            Column {
                width: parent.width - 32 - actionBtn.width - 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    text: Control.ethModel !== "" ? Control.ethModel : "Internal Cable Adapter"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: `${Control.ethDevice || "eth0"}${Control.ethSpeedText !== "" ? "  ·  " + Control.ethSpeedText : ""}${Control.ethConnected ? "  ·  Connected" : (Control.ethCarrier ? "  ·  Plugged" : "  ·  Unplugged")}`
                    color: Control.ethConnected ? Theme.fgDim : Theme.fgFaint
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                    elide: Text.ElideRight
                }
            }

            // Connect / Disconnect button
            Rectangle {
                id: actionBtn

                anchors.verticalCenter: parent.verticalCenter
                width: btnText.implicitWidth + 18
                height: 24
                radius: Theme.chipRadius
                color: btnMouse.containsMouse ? Theme.hover : Theme.pressed
                border.width: 1
                border.color: Control.ethConnected ? Qt.rgba(Theme.good.r, Theme.good.g, Theme.good.b, 0.4) : Theme.islandBorder

                Behavior on color {
                    ColorAnimation { duration: Theme.durSnappy }
                }

                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text: Control.ethConnected ? "Disconnect" : "Connect"
                    color: Control.ethConnected ? Theme.good : Theme.fg
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Control.toggleEth()
                }
            }
        }

        // ---- Thin divider ---------------------------------------------------
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.25
        }

        // ---- Network details: IP, Gateway, MAC, Link Status -----------------
        Row {
            width: parent.width
            spacing: 6

            // Clickable IP pill
            Rectangle {
                height: 22
                width: (parent.width - 6) / 2
                radius: Theme.chipRadius
                color: ipMouse.containsMouse ? Theme.hover : Theme.tint
                border.width: 1
                border.color: root.ipCopied ? Theme.good : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Theme.durSnappy }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.ipCopied ? "󰄬" : "󰩟"
                        color: root.ipCopied ? Theme.good : Theme.accent
                        font.family: Theme.iconFamily
                        renderType: Text.QtRendering
                        font.pixelSize: 11
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.ipCopied ? "IP Copied" : (Control.ethIp !== "" ? Control.ethIp : "No IP")
                        color: root.ipCopied ? Theme.good : (Control.ethIp !== "" ? Theme.fg : Theme.fgFaint)
                        font.family: Theme.fontFamily
                        renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                        font.weight: root.ipCopied ? Font.DemiBold : Font.Normal
                    }
                }

                MouseArea {
                    id: ipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Control.ethIp !== "") {
                            const cleanIp = Control.ethIp.split("/")[0];
                            Control.copyToClipboard(cleanIp);
                            root.ipCopied = true;
                            copiedTimer.restart();
                        }
                    }
                }
            }

            // Gateway pill
            Rectangle {
                height: 22
                width: (parent.width - 6) / 2
                radius: Theme.chipRadius
                color: Theme.tint

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰌘"
                        color: Theme.fgDim
                        font.family: Theme.iconFamily
                        renderType: Text.QtRendering
                        font.pixelSize: 11
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Control.ethGateway !== "" ? `GW: ${Control.ethGateway}` : "GW: None"
                        color: Theme.fgDim
                        font.family: Theme.fontFamily
                        renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 2
                    }
                }
            }
        }

        // Secondary Info line: MAC and Hardware Driver
        Row {
            width: parent.width
            spacing: 8

            Text {
                text: Control.ethMac !== "" ? `MAC: ${Control.ethMac.toUpperCase()}` : ""
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 2
                visible: text !== ""
            }

            Text {
                text: "·"
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 2
                visible: Control.ethMac !== "" && Control.ethCarrier
            }

            Text {
                text: Control.ethCarrier ? (Control.ethSpeedText !== "" ? `Speed: ${Control.ethSpeedText}` : "Carrier: Active") : "Carrier: Disconnected"
                color: Control.ethCarrier ? Theme.fgDim : Theme.warn
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 2
            }
        }
    }
}
