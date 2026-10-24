import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

Item {
    id: root

    property string tab: "perf"   // "perf" | "weather" | "info"

    implicitHeight: column.implicitHeight + Theme.panelPad * 2

    function tempColor(celsius) {
        if (celsius === null || celsius === undefined) return Theme.fg;
        if (celsius >= 80) return Theme.urgent;
        if (celsius >= 65) return Theme.warn;
        return Theme.fg;
    }

    function tempText(celsius) {
        return celsius === null || celsius === undefined ? "--" : Math.round(celsius) + "°";
    }

    function dayNameFromDate(dateStr) {
        if (!dateStr) return "";
        const parts = dateStr.split("-");
        if (parts.length < 3) return dateStr;
        const d = new Date(parts[0], parts[1] - 1, parts[2]);
        return d.toLocaleDateString(Qt.locale(), "ddd");
    }

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.panelPad
        }
        spacing: 10

        // ---- Tab Switcher Header (Material Segmented Pills) -----------------
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Repeater {
                model: [
                    { id: "perf", label: "Performance", icon: "󰓅" },
                    { id: "weather", label: "Weather", icon: "󰖐" },
                    { id: "info", label: "System", icon: "󰋼" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    readonly property bool active: root.tab === modelData.id

                    width: tabText.implicitWidth + 24
                    height: 26
                    radius: 13
                    color: active ? Theme.pressed : tabMouse.containsMouse ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: active ? Theme.islandBorder : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Row {
                        id: tabText
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: modelData.icon
                            color: active ? Theme.accent : Theme.fgDim
                            font.family: Theme.iconFamily
                            renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text: modelData.label
                            color: active ? Theme.fg : Theme.fgDim
                            font.family: Theme.fontFamily
                            renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: active ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tab = modelData.id
                    }
                }
            }
        }

        // =====================================================================
        // TAB 1: PERFORMANCE (Celestia HeroCards + Sparkline)
        // =====================================================================
        Column {
            width: parent.width
            spacing: 10
            visible: root.tab === "perf"

            // Dual Hero Cards: CPU and GPU
            Row {
                width: parent.width
                spacing: 8

                // CPU Hero Card
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 82
                    radius: Theme.chipRadius + 2
                    color: Theme.tint
                    border.width: 1
                    border.color: Theme.islandBorder

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        CircularProgress {
                            anchors.verticalCenter: parent.verticalCenter
                            value: SystemInfo.cpuRatio
                            fgColor: SystemInfo.cpuRatio > 0.85 ? Theme.urgent : Theme.accent
                            strokeWidth: 4
                            implicitWidth: 44
                            implicitHeight: 44

                            Text {
                                anchors.centerIn: parent
                                text: Math.round(SystemInfo.cpuRatio * 100) + "%"
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44 - 10
                            spacing: 2

                            Text {
                                text: "CPU"
                                color: Theme.accent
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Bold
                            }

                            Text {
                                width: parent.width
                                text: SystemInfo.cpuModel.replace(/Processor|8-Core|Core.*$/g, "").trim() || "Ryzen"
                                color: Theme.fgDim
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall - 2
                                elide: Text.ElideRight
                            }

                            Row {
                                spacing: 3
                                Text {
                                    text: "󰔏"
                                    color: root.tempColor(SystemInfo.cpuTemp)
                                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: root.tempText(SystemInfo.cpuTemp)
                                    color: root.tempColor(SystemInfo.cpuTemp)
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: Theme.fontSizeSmall - 1
                                    font.weight: Font.Medium
                                }
                            }
                        }
                    }
                }

                // GPU Hero Card
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 82
                    radius: Theme.chipRadius + 2
                    color: Theme.tint
                    border.width: 1
                    border.color: Theme.islandBorder

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        CircularProgress {
                            anchors.verticalCenter: parent.verticalCenter
                            value: SystemInfo.gpuUsage
                            fgColor: SystemInfo.gpuUsage > 0.85 ? Theme.urgent : Theme.good
                            strokeWidth: 4
                            implicitWidth: 44
                            implicitHeight: 44

                            Text {
                                anchors.centerIn: parent
                                text: Math.round(SystemInfo.gpuUsage * 100) + "%"
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44 - 10
                            spacing: 2

                            Text {
                                text: "GPU"
                                color: Theme.good
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Bold
                            }

                            Text {
                                width: parent.width
                                text: SystemInfo.gpuModel.replace(/PowerColor|Red Devil/g, "").trim() || "Radeon"
                                color: Theme.fgDim
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall - 2
                                elide: Text.ElideRight
                            }

                            Row {
                                spacing: 3
                                Text {
                                    text: "󰔏"
                                    color: root.tempColor(SystemInfo.gpuTemp)
                                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: root.tempText(SystemInfo.gpuTemp)
                                    color: root.tempColor(SystemInfo.gpuTemp)
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: Theme.fontSizeSmall - 1
                                    font.weight: Font.Medium
                                }
                            }
                        }
                    }
                }
            }

            // RAM & Storage
            Column {
                width: parent.width
                spacing: 6

                StatBar {
                    width: parent.width
                    label: "Memory"
                    ratio: SystemInfo.memRatio
                    value: SystemInfo.gib(SystemInfo.memUsedMib) + " / " + SystemInfo.gib(SystemInfo.memTotalMib) + " G"
                    barColor: SystemInfo.memRatio > 0.9 ? Theme.urgent : Theme.accent
                }

                StatBar {
                    width: parent.width
                    label: "Disk /"
                    ratio: SystemInfo.diskRatio
                    value: SystemInfo.gibFromBytes(SystemInfo.diskUsed) + " / " + SystemInfo.gibFromBytes(SystemInfo.diskTotal) + " G"
                    barColor: SystemInfo.diskRatio > 0.9 ? Theme.urgent : Theme.fg
                }
            }

            // Live Network Sparkline Card (Celestia-Style Network History)
            Rectangle {
                width: parent.width
                height: 94
                radius: Theme.chipRadius + 2
                color: Theme.tint
                border.width: 1
                border.color: Theme.islandBorder

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Item {
                        width: parent.width
                        height: 18

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                text: "󰛳"
                                color: Theme.accent
                                font.family: Theme.iconFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.iconSize
                            }
                            Text {
                                text: SystemInfo.iface || "Network"
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.DemiBold
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Text {
                                text: `↓ ${SystemInfo.formatRate(SystemInfo.rxRate)}`
                                color: Theme.accent
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall - 1
                                font.weight: Font.Medium
                            }

                            Text {
                                text: `↑ ${SystemInfo.formatRate(SystemInfo.txRate)}`
                                color: Theme.good
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall - 1
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Sparkline {
                        width: parent.width
                        height: 52
                        rxHistory: SystemInfo.rxHistory
                        txHistory: SystemInfo.txHistory
                        rxColor: Theme.accent
                        txColor: Theme.good
                    }
                }
            }

            // Secondary Sensors (NVMe + Buds)
            Row {
                width: parent.width
                spacing: 12
                visible: SystemInfo.nvmeTemp !== null || InzoneBuds.present

                Row {
                    spacing: 4
                    visible: SystemInfo.nvmeTemp !== null
                    Text {
                        text: "NVMe:"
                        color: Theme.fgFaint
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 1
                    }
                    Text {
                        text: root.tempText(SystemInfo.nvmeTemp)
                        color: root.tempColor(SystemInfo.nvmeTemp)
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 1
                        font.weight: Font.Medium
                    }
                }

                Row {
                    spacing: 4
                    visible: InzoneBuds.present
                    Text {
                        text: InzoneBuds.iconFor(InzoneBuds.worst)
                        color: InzoneBuds.low ? Theme.urgent : Theme.fgDim
                        font.family: Theme.iconFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.iconSize - 2
                    }
                    Text {
                        text: `Buds ${InzoneBuds.summary}`
                        color: InzoneBuds.low ? Theme.urgent : Theme.fgDim
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: Theme.fontSizeSmall - 1
                    }
                }
            }
        }

        // =====================================================================
        // TAB 2: WEATHER (Celestia-Style Astronomy + 3-Day Forecast)
        // =====================================================================
        Column {
            width: parent.width
            spacing: 10
            visible: root.tab === "weather"

            // Current Weather Condition Banner
            Rectangle {
                width: parent.width
                height: 90
                radius: Theme.chipRadius + 2
                color: Theme.tint
                border.width: 1
                border.color: Theme.islandBorder

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 14

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Weather.icon
                        color: Theme.accent
                        font.family: Theme.iconFamily; renderType: Text.QtRendering
                        font.pixelSize: 42
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Row {
                            spacing: 8
                            Text {
                                text: Weather.ok ? Weather.tempC + "°C" : "Unavailable"
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: 22
                                font.weight: Font.Bold
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
                            text: Weather.ok ? `${Weather.displayLocation}  ·  feels ${Weather.feelsC}°` : "Checking weather..."
                            color: Theme.fgFaint
                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSizeSmall - 1
                        }

                        Text {
                            text: Weather.ok ? `H: ${Weather.maxC}°  L: ${Weather.minC}°  ·  󰖗 ${Weather.chanceOfRain}% rain` : ""
                            color: Theme.fgDim
                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSizeSmall - 2
                            visible: Weather.ok
                        }
                    }
                }
            }

            // Astronomy & Conditions Grid (Sunrise, Sunset, Humidity, Wind)
            Row {
                width: parent.width
                spacing: 6

                Repeater {
                    model: [
                        { icon: "󰖜", label: "Sunrise", val: Weather.sunrise || "--:--" },
                        { icon: "󰖛", label: "Sunset", val: Weather.sunset || "--:--" },
                        { icon: "󰖎", label: "Humidity", val: `${Weather.humidity}%` },
                        { icon: "󰖝", label: "Wind", val: `${Weather.windKmph} km/h` }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width: (root.width - Theme.panelPad * 2 - 18) / 4
                        height: 52
                        radius: Theme.chipRadius
                        color: Theme.tint
                        border.width: 1
                        border.color: Theme.islandBorder

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 4
                                Text {
                                    text: modelData.icon
                                    color: Theme.accent
                                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: modelData.label
                                    color: Theme.fgFaint
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: 9
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.val
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: Theme.fontSizeSmall - 1
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            // 3-Day Forecast Strip
            Column {
                width: parent.width
                spacing: 4
                visible: Weather.forecast && Weather.forecast.length > 0

                Text {
                    text: "3-DAY FORECAST"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: Weather.forecast

                        delegate: Rectangle {
                            required property var modelData

                            width: (root.width - Theme.panelPad * 2 - 12) / 3
                            height: 64
                            radius: Theme.chipRadius
                            color: Theme.tint
                            border.width: 1
                            border.color: Theme.islandBorder

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.dayNameFromDate(modelData.date)
                                    color: Theme.fgDim
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: Theme.fontSizeSmall - 1
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Weather.iconForCode(modelData.code)
                                    color: Theme.accent
                                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                                    font.pixelSize: 16
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: `${modelData.maxC}° / ${modelData.minC}°`
                                    color: Theme.fg
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: Theme.fontSizeSmall - 2
                                }
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // TAB 3: HARDWARE & SYSTEM DETAILS
        // =====================================================================
        Column {
            width: parent.width
            spacing: 6
            visible: root.tab === "info"

            InfoRow {
                width: parent.width
                label: "UPTIME"
                value: SystemInfo.uptimeText
            }

            InfoRow {
                width: parent.width
                label: "OS"
                value: SystemInfo.osName === "" ? "Linux" : `${SystemInfo.osName}`
                valueColor: Theme.fg
            }

            InfoRow {
                width: parent.width
                label: "KERNEL"
                value: SystemInfo.kernel
                valueColor: Theme.fgDim
            }

            InfoRow {
                width: parent.width
                label: "CPU"
                value: SystemInfo.cpuModel
                valueColor: Theme.fgDim
            }

            InfoRow {
                width: parent.width
                label: "GPU"
                value: SystemInfo.gpuModel
                valueColor: Theme.fgDim
            }

            InfoRow {
                width: parent.width
                label: "LOAD"
                value: `${SystemInfo.load1.toFixed(2)} (${SystemInfo.cores} cores)`
                valueColor: Theme.fgDim
            }
        }
    }
}
