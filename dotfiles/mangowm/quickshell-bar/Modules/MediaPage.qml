import QtQuick
import Quickshell.Widgets
import "../Config"
import "../Services"
import "../Widgets"

Item {
    id: root

    Row {
        anchors.fill: parent
        anchors.margins: Theme.panelPad
        spacing: 12

        // Album art, when the player publishes any.
        ClippingRectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 64
            radius: 12
            color: Theme.wsEmpty
            visible: Media.hasPlayer

            Image {
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: Media.artUrl === ""
                text: "󰝚"
                color: Theme.fgFaint
                font.family: Theme.iconFamily; renderType: Text.QtRendering
                font.pixelSize: 26
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 64 - parent.spacing
            spacing: 6

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: Media.title || "Nothing playing"
                color: Theme.fg
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: Media.artist || Media.identity
                color: Theme.fgDim
                font.family: Theme.fontFamily; renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall
                visible: text !== ""
            }

            Row {
                spacing: 4

                IconButton {
                    glyph: "󰒮"
                    size: 30
                    glyphSize: 16
                    enabled: Media.canPrevious
                    onActivated: Media.previous()
                }

                IconButton {
                    glyph: Media.playing ? "󰏤" : "󰐊"
                    size: 30
                    glyphSize: 18
                    idleColor: Theme.fg
                    onActivated: Media.toggle()
                }

                IconButton {
                    glyph: "󰒭"
                    size: 30
                    glyphSize: 16
                    enabled: Media.canNext
                    onActivated: Media.next()
                }
            }
        }
    }
}
