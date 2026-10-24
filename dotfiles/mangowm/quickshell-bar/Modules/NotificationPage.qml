import QtQuick
import Quickshell
import Quickshell.Widgets
import "../Config"
import "../Services"
import "../Widgets"

// Notification Center Popover.
// Lists active notifications with rich details, action buttons, urgency indicators,
// and quick controls for Do-Not-Disturb and Clear All.
Item {
    id: root

    implicitWidth: Theme.notificationPageWidth
    implicitHeight: Theme.notificationPageHeight

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPad
        spacing: 10

        // ---- Header --------------------------------------------------------
        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    text: "󰂚"
                    color: Theme.accent
                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Notifications"
                    color: Theme.fg
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    visible: Notifs.count > 0
                    width: Math.max(18, countText.implicitWidth + 8)
                    height: 18
                    radius: 9
                    color: Theme.highlight
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: Notifs.count
                        color: Theme.fg
                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Do Not Disturb Toggle Button
                Rectangle {
                    width: dndRow.implicitWidth + 12
                    height: 24
                    radius: Theme.chipRadius
                    color: Notifs.dnd ? Theme.urgent : dndMouse.containsMouse ? Theme.hover : Theme.tint

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Row {
                        id: dndRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: Notifs.dnd ? "󰂛" : "󰂚"
                            color: Notifs.dnd ? Theme.onAccent : Theme.fgDim
                            font.family: Theme.iconFamily; renderType: Text.QtRendering
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "DND"
                            color: Notifs.dnd ? Theme.onAccent : Theme.fgDim
                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: dndMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.toggleDnd()
                    }
                }

                // Clear All Button
                Rectangle {
                    visible: Notifs.count > 0
                    width: clearRow.implicitWidth + 12
                    height: 24
                    radius: Theme.chipRadius
                    color: clearMouse.containsMouse ? Theme.hover : Theme.tint

                    Behavior on color {
                        ColorAnimation { duration: Theme.durSnappy }
                    }

                    Row {
                        id: clearRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "󰆴"
                            color: clearMouse.containsMouse ? Theme.urgent : Theme.fgFaint
                            font.family: Theme.iconFamily; renderType: Text.QtRendering
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Clear all"
                            color: clearMouse.containsMouse ? Theme.urgent : Theme.fgDim
                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dismissAll()
                    }
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.islandBorder
        }

        // ---- Body / Notification List ---------------------------------------
        Item {
            width: parent.width
            height: parent.height - 40
            clip: true

            // Empty State
            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: Notifs.count === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Notifs.dnd ? "󰂛" : "󰂜"
                    color: Theme.fgFaint
                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                    font.pixelSize: 42
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Notifs.dnd ? "Do Not Disturb is active" : "No Notifications"
                    color: Theme.fgDim
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Notifs.dnd ? "Popups and alerts are muted" : "You're all caught up"
                    color: Theme.fgFaint
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            // Scrollable List
            ListView {
                id: notifList
                anchors.fill: parent
                visible: Notifs.count > 0
                clip: true
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds

                model: Notifs.list

                delegate: Rectangle {
                    id: card
                    width: notifList.width
                    implicitHeight: cardContent.implicitHeight + 16
                    radius: 12
                    color: cardArea.containsMouse ? Theme.hover : Theme.tint
                    border.width: 1
                    border.color: modelData.urgency === 2 ? Theme.urgent : cardArea.containsMouse ? Theme.highlight : Theme.islandBorder

                    Behavior on color { ColorAnimation { duration: Theme.durSnappy } }
                    Behavior on border.color { ColorAnimation { duration: Theme.durSnappy } }

                    MouseArea {
                        id: cardArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Row {
                        id: cardContent
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 8
                        }
                        spacing: 10

                        // App Icon or Avatar
                        Item {
                            width: 34
                            height: 34
                            anchors.top: parent.top

                            Image {
                                id: rawImg
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                source: modelData.image !== "" ? modelData.image : (modelData.appIcon.startsWith("/") || modelData.appIcon.startsWith("file://")) ? modelData.appIcon : ""
                                visible: source !== "" && status === Image.Ready
                            }

                            IconImage {
                                id: iconImg
                                anchors.fill: parent
                                source: !rawImg.visible && modelData.appIcon !== "" ? Quickshell.iconPath(modelData.appIcon, "dialog-information") : ""
                                visible: !rawImg.visible && source !== ""
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: Theme.hover
                                visible: !rawImg.visible && !iconImg.visible

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂚"
                                    color: modelData.urgency === 2 ? Theme.urgent : Theme.accent
                                    font.family: Theme.iconFamily; renderType: Text.QtRendering
                                    font.pixelSize: 16
                                }
                            }
                        }

                        // Notification Details
                        Column {
                            width: parent.width - 44
                            spacing: 3

                            // Header: App name + time + dismiss button
                            Item {
                                width: parent.width
                                height: 16

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: timeRow.left
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.appName
                                    color: Theme.fgDim
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Row {
                                    id: timeRow
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Text {
                                        text: modelData.timeStr
                                        color: Theme.fgFaint
                                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Dismiss button
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 4
                                        color: closeMouse.containsMouse ? Theme.highlight : "transparent"
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰅖"
                                            color: closeMouse.containsMouse ? Theme.urgent : Theme.fgFaint
                                            font.family: Theme.iconFamily; renderType: Text.QtRendering
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            id: closeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.dismiss()
                                        }
                                    }
                                }
                            }

                            // Summary / Title
                            Text {
                                width: parent.width
                                text: modelData.summary
                                color: Theme.fg
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }

                            // Body
                            Text {
                                width: parent.width
                                text: modelData.body
                                color: Theme.fgDim
                                font.family: Theme.fontFamily; renderType: Text.QtRendering
                                font.pixelSize: 11
                                textFormat: Text.StyledText
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }

                            // Actions
                            Row {
                                width: parent.width
                                spacing: 6
                                visible: modelData.actions && modelData.actions.length > 0
                                topPadding: 4

                                Repeater {
                                    model: modelData.actions

                                    Rectangle {
                                        width: actionText.implicitWidth + 14
                                        height: 22
                                        radius: 6
                                        color: actMouse.containsMouse ? Theme.highlight : Theme.hover
                                        border.width: 1
                                        border.color: actMouse.containsMouse ? Theme.accent : Theme.islandBorder

                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            color: actMouse.containsMouse ? Theme.accent : Theme.fg
                                            font.family: Theme.fontFamily; renderType: Text.QtRendering
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                        }

                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: model.modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
