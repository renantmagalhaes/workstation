import QtQuick
import Quickshell.Widgets
import "../Config"
import "../Services"
import "../Widgets"

// Reports its own implicitHeight so the panel shrinks when a player exposes no
// position and there is only one of them.
Item {
    id: root

    implicitHeight: column.implicitHeight + Theme.panelPad * 2

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.panelPad
        }
        spacing: 8

        Row {
            width: parent.width
            spacing: 12

            // Album art, when the player publishes any.
            ClippingRectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: 64
                radius: 12
                color: Theme.wsEmpty

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
                    font.family: Theme.iconFamily
                    renderType: Text.QtRendering
                    font.pixelSize: 26
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 64 - parent.spacing
                spacing: 4

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Media.title || "Nothing playing"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Media.artist || Media.identity
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                    visible: text !== ""
                }

                Row {
                    spacing: 4

                    IconButton {
                        glyph: "󰒮"
                        size: 30
                        glyphSize: 16
                        enabled: Media.canPrevious || Media.seekable
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

        // ---- Seek bar ---------------------------------------------------------
        // Only for players that actually report a length; plenty of them lie or
        // simply do not support it, and a dead scrubber is worse than none.
        Item {
            width: parent.width
            height: 22
            visible: Media.seekable

            Text {
                id: elapsed

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Media.formatTime(Media.position)
                color: Theme.fgDim
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 1
            }

            Text {
                id: total

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Media.formatTime(Media.duration)
                color: Theme.fgDim
                font.family: Theme.fontFamily
                renderType: Text.QtRendering
                font.pixelSize: Theme.fontSizeSmall - 1
            }

            LevelSlider {
                anchors.left: elapsed.right
                anchors.right: total.left
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                value: Media.progress
                wheelStep: 0.02
                onRequested: fraction => Media.seek(fraction)
            }
        }

        // ---- Player picker ----------------------------------------------------
        // Vertical list: one row per player, full panel width. Scales to any
        // number of sources and elides long KDE Connect names cleanly.
        Column {
            width: parent.width
            spacing: 2
            visible: Media.players.length > 0

            Repeater {
                model: Media.players

                delegate: Rectangle {
                    id: chip

                    required property var modelData

                    readonly property bool current: modelData === Media.active

                    width: parent.width
                    height: 26
                    radius: Theme.chipRadius
                    color: chip.current ? Theme.pressed : chipArea.containsMouse ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: chip.current ? Theme.islandBorder : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Rectangle {
                            id: dot
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 5
                            height: 5
                            radius: 3
                            color: chip.current ? Theme.accent : Theme.fgFaint

                            Behavior on color {
                                ColorAnimation { duration: Theme.durSnappy }
                            }
                        }

                        Text {
                            anchors.left: dot.right
                            anchors.leftMargin: 7
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            text: modelData?.identity ?? "Player"
                            color: chip.current ? Theme.fg : Theme.fgDim
                            font.family: Theme.fontFamily
                            renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSizeSmall - 1
                            font.weight: chip.current ? Font.DemiBold : Font.Normal

                            Behavior on color {
                                ColorAnimation { duration: Theme.durSnappy }
                            }
                        }
                    }

                    MouseArea {
                        id: chipArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Media.pick(chip.modelData)
                    }
                }
            }
        }
    }
}
