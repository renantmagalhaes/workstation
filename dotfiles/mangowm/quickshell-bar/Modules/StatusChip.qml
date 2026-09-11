import QtQuick
import "../Config"
import "../Services"

// Compact weather + hottest-sensor readout. Replaces waybar's status capsule
// (custom/weather + custom/systeminfo); the detail lives in SystemPage.
Item {
    id: root

    property bool active: false
    signal activated

    function tempColor(celsius) {
        if (celsius === null || celsius === undefined) return Theme.fgDim;
        if (celsius >= 80) return Theme.urgent;
        if (celsius >= 65) return "#F4C46B";
        return Theme.fgDim;
    }

    implicitWidth: row.implicitWidth + Theme.capsulePadH * 2
    implicitHeight: Theme.islandHeight

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        radius: Theme.chipRadius
        color: root.active ? Theme.pressed : mouse.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.icon
            color: Theme.fg
            font.family: Theme.iconFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.ok ? Weather.tempC + "°" : "--"
            color: Theme.fg
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰔏"
            color: root.tempColor(SystemInfo.peakTemp)
            font.family: Theme.iconFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.iconSize
            visible: SystemInfo.peakTemp !== null

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durNormal
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: SystemInfo.peakTemp !== null ? Math.round(SystemInfo.peakTemp) + "°" : ""
            color: root.tempColor(SystemInfo.peakTemp)
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            visible: SystemInfo.peakTemp !== null
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
