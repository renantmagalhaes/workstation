import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../Config"
import "../Services"

// Desktop Notification Popups (Toasts) at the top-right of the screen.
// Appears when a notification arrives, auto-dismisses after timeout,
// and stays recorded in the island Notification Center.
PanelWindow {
    id: toastWindow

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.topMargin + 8
        right: 16
    }

    implicitWidth: 380
    implicitHeight: Math.max(Notifs.popups.length > 0 ? 80 : 1, toastCol.childrenRect.height + 10)

    visible: Notifs.popups.length > 0

    Column {
        id: toastCol
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups

            delegate: Rectangle {
                id: card
                width: toastCol.width
                height: Math.max(76, cardContent.implicitHeight + 20)
                radius: 14
                color: Theme.islandBg
                border.width: 1
                border.color: modelData.urgency === 2 ? Theme.urgent : cardMouse.containsMouse ? Theme.highlight : Theme.islandBorder

                // Lit bevel top highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.alpha("#FFFFFF", 0.08)
                }

                Behavior on border.color { ColorAnimation { duration: Theme.durSnappy } }

                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: modelData.hovered = true
                    onExited: modelData.hovered = false
                    onClicked: modelData.dismissPopup()
                }

                Row {
                    id: cardContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 10
                    }
                    spacing: 10

                    // App Icon or avatar
                    Item {
                        width: 36
                        height: 36
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
                                font.pixelSize: 18
                            }
                        }
                    }

                    // Details
                    Column {
                        width: parent.width - 48
                        spacing: 3

                        // Header row: App Name + Urgency tag + Close button
                        Item {
                            width: parent.width
                            height: 16

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Text {
                                    text: modelData.appName
                                    color: Theme.fgDim
                                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: modelData.urgency === 2
                                    width: 48
                                    height: 14
                                    radius: 3
                                    color: Theme.urgent
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "CRITICAL"
                                        color: Theme.onAccent
                                        font.family: Theme.fontFamily; renderType: Text.QtRendering
                                        font.pixelSize: 8
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            // Close button
                            Rectangle {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                height: 18
                                radius: 4
                                color: closeMouse.containsMouse ? Theme.highlight : "transparent"

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
                                    onClicked: modelData.dismissPopup()
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
                            maximumLineCount: 3
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
                                        onClicked: {
                                            model.modelData.invoke();
                                            modelData.dismissPopup();
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
