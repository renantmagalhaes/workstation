import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

Item {
    id: root

    function tempColor(celsius) {
        if (celsius === null || celsius === undefined) return Theme.fg;
        if (celsius >= 80) return Theme.urgent;
        if (celsius >= 65) return "#F4C46B";
        return Theme.fg;
    }

    function tempText(celsius) {
        return celsius === null || celsius === undefined ? "--" : Math.round(celsius) + "°";
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPad
        spacing: 8

        // ---- Weather ---------------------------------------------------------
        Row {
            width: parent.width
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Weather.icon
                color: Theme.fg
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: 32
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 44 - parent.spacing
                spacing: 2

                Row {
                    spacing: 8

                    Text {
                        text: Weather.ok ? Weather.tempC + "°C" : "Unavailable"
                        color: Theme.fg
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSize + 3
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.baseline: parent.children[0].baseline
                        text: Weather.description
                        color: Theme.fgDim
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Weather.ok ? `${Weather.location}  ·  feels ${Weather.feelsC}°  ·  ${Weather.humidity}%  ·  ${Weather.windKmph} km/h` : "No weather data"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 1
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.5
        }

        // ---- Resources -------------------------------------------------------
        StatBar {
            width: parent.width
            label: "Load"
            ratio: SystemInfo.cpuRatio
            value: SystemInfo.load1.toFixed(2) + " / " + SystemInfo.cores
            barColor: SystemInfo.cpuRatio > 0.85 ? Theme.urgent : Theme.fg
        }

        StatBar {
            width: parent.width
            label: "Memory"
            ratio: SystemInfo.memRatio
            value: SystemInfo.gib(SystemInfo.memUsedMib) + " / " + SystemInfo.gib(SystemInfo.memTotalMib) + " G"
            barColor: SystemInfo.memRatio > 0.9 ? Theme.urgent : Theme.fg
        }

        StatBar {
            width: parent.width
            label: "Disk"
            ratio: SystemInfo.diskRatio
            value: SystemInfo.gibFromBytes(SystemInfo.diskUsed) + " / " + SystemInfo.gibFromBytes(SystemInfo.diskTotal) + " G"
            barColor: SystemInfo.diskRatio > 0.9 ? Theme.urgent : Theme.fg
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.5
        }

        // ---- Temperatures ----------------------------------------------------
        Row {
            width: parent.width

            Repeater {
                model: [
                    {
                        label: "CPU",
                        value: SystemInfo.cpuTemp
                    },
                    {
                        label: "GPU",
                        value: SystemInfo.gpuTemp
                    },
                    {
                        label: "NVMe",
                        value: SystemInfo.nvmeTemp
                    }
                ]

                delegate: Column {
                    required property var modelData

                    width: root.width / 3 - Theme.panelPad
                    spacing: 1

                    Text {
                        text: modelData.label
                        color: Theme.fgFaint
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 1
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.tempText(modelData.value)
                        color: root.tempColor(modelData.value)
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durNormal
                            }
                        }
                    }
                }
            }
        }

        // ---- Peripheral battery (only when a device reports) -----------------
        Row {
            width: parent.width
            spacing: 6
            visible: Battery.hasAny

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Battery.icon
                color: Battery.low ? Theme.urgent : Theme.fg
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.iconSize
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: `${Battery.deviceName}  ${Battery.percent}%`
                color: Battery.low ? Theme.urgent : Theme.fgDim
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
