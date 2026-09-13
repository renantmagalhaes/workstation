import QtQuick
import "../Config"

// Theme swatches plus the blur switch.
//
// Each swatch previews the scheme it selects -- filled with that palette's own
// background and ringed in its accent -- so the choice is visible without
// applying it. Selecting writes to Settings, which persists and applies live.
Item {
    id: root

    implicitHeight: column.implicitHeight

    Column {
        id: column

        width: parent.width
        spacing: 6

        Text {
            text: "THEME"
            color: Theme.fgFaint
            font.family: Theme.fontFamily
            renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall - 2
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        Row {
            spacing: 6

            Repeater {
                model: Palettes.list

                delegate: Item {
                    id: swatch

                    required property var modelData

                    readonly property bool current: Settings.theme === modelData.id

                    width: 36
                    height: 36

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 10
                        color: swatch.modelData.bg
                        border.width: swatch.current ? 2 : 1
                        border.color: swatch.current ? swatch.modelData.accent : Qt.alpha(swatch.modelData.fg, 0.25)

                        Behavior on border.width {
                            NumberAnimation {
                                duration: Theme.durSnappy
                            }
                        }

                        // Accent dot, or a tick once selected.
                        Rectangle {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            radius: 6
                            color: swatch.modelData.accent
                            visible: !swatch.current
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: swatch.current
                            text: "󰄬"
                            color: swatch.modelData.accent
                            font.family: Theme.iconFamily
                            renderType: Text.QtRendering
                            font.pixelSize: Theme.fontSize
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: area.containsMouse && !swatch.current ? Theme.hover : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durSnappy
                            }
                        }
                    }

                    MouseArea {
                        id: area

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.theme = swatch.modelData.id
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: 24

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Text {
                    text: Theme.palette.name
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                }

                Text {
                    text: Theme.palette.note
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 2
                }
            }

            // Blur is a property of the look rather than of the palette, so any
            // scheme can be run solid or translucent.
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: blurLabel.implicitWidth + 34
                height: 24
                radius: Theme.chipRadius
                color: Settings.blur ? Theme.pressed : blurArea.containsMouse ? Theme.hover : Theme.tint

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durSnappy
                    }
                }

                Text {
                    id: blurGlyph

                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: Settings.blur ? "󰔖" : "󰸉"
                    color: Settings.blur ? Theme.accent : Theme.fgDim
                    font.family: Theme.iconFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    id: blurLabel

                    anchors.left: blurGlyph.right
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Blur"
                    color: Settings.blur ? Theme.fg : Theme.fgDim
                    font.family: Theme.fontFamily
                    renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall - 1
                    font.weight: Settings.blur ? Font.DemiBold : Font.Normal
                }

                MouseArea {
                    id: blurArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Settings.blur = !Settings.blur
                }
            }
        }
    }
}
