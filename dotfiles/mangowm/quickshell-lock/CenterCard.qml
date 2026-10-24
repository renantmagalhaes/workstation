pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property PamAuth pam
    property string username: "rtm"

    implicitWidth: 460
    implicitHeight: 460

    // Shake animation on authentication failure
    SequentialAnimation {
        id: shakeAnim
        running: false
        loops: 1

        NumberAnimation { target: cardBody; property: "x"; from: 0; to: -16; duration: 40; easing.type: Easing.OutQuad }
        NumberAnimation { target: cardBody; property: "x"; from: -16; to: 16; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardBody; property: "x"; from: 16; to: -10; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardBody; property: "x"; from: -10; to: 10; duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardBody; property: "x"; from: 10; to: 0; duration: 40; easing.type: Easing.OutQuad }
    }

    Connections {
        target: root.pam
        function onFailedAuth() {
            shakeAnim.restart();
        }
    }

    ColumnLayout {
        id: cardBody
        anchors.centerIn: parent
        spacing: 20

        // Clock & Date
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                id: clockText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(new Date(), "HH:mm")
                font.family: "Inter, Noto Sans, sans-serif"
                font.pixelSize: 84
                font.weight: Font.DemiBold
                color: "#FFFFFF"

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                font.family: "Inter, Noto Sans, sans-serif"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Qt.rgba(1, 1, 1, 0.70)

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
                }
            }
        }

        // Avatar & Username
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 84
                height: 84
                radius: 42
                color: Qt.rgba(0.12, 0.12, 0.18, 0.70)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 2
                clip: true

                Image {
                    id: avatarImg
                    anchors.fill: parent
                    source: "file:///home/" + root.username + "/.face"
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 38
                    color: Qt.rgba(1, 1, 1, 0.6)
                    visible: !avatarImg.visible
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.username
                font.family: "Inter, Noto Sans, sans-serif"
                font.pixelSize: 17
                font.bold: true
                color: "#FFFFFF"
            }
        }

        // Password Input Pill
        Rectangle {
            id: inputPill
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 320
            Layout.preferredHeight: 52
            radius: 26

            color: root.pam?.failed
                ? Qt.rgba(0.35, 0.08, 0.10, 0.85)
                : Qt.rgba(0.10, 0.10, 0.15, 0.75)

            border.color: root.pam?.failed
                ? "#FF5555"
                : ((root.pam?.buffer.length ?? 0) > 0 ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.18))
            border.width: root.pam?.failed ? 2 : ((root.pam?.buffer.length ?? 0) > 0 ? 1.5 : 1)

            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            // Click focus trap
            MouseArea {
                anchors.fill: parent
                onClicked: keyTrap.forceActiveFocus()
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 12
                spacing: 12

                // Lock icon or Spinner
                Text {
                    text: root.pam?.active ? "" : (root.pam?.failed ? "" : "")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.pam?.failed ? "#FF5555" : ((root.pam?.buffer.length ?? 0) > 0 ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.5))

                    RotationAnimator on rotation {
                        running: root.pam?.active ?? false
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 800
                    }
                }

                // Password Display Area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Placeholder / Status Text
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        text: root.pam?.active
                            ? "Verifying..."
                            : (root.pam?.failed ? (root.pam?.errorMessage || "Incorrect password") : "Password...")
                        font.family: "Inter, Noto Sans, sans-serif"
                        font.pixelSize: 14
                        color: root.pam?.failed
                            ? "#FFAAAA"
                            : Qt.rgba(1, 1, 1, 0.40)
                        visible: (root.pam?.buffer.length ?? 0) === 0 || (root.pam?.active ?? false)
                    }

                    // Dots row
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        spacing: 6
                        visible: (root.pam?.buffer.length ?? 0) > 0 && !(root.pam?.active ?? false)

                        Repeater {
                            model: root.pam?.buffer.length ?? 0

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#FFFFFF"
                            }
                        }
                    }
                }

                // Submit Button
                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 17
                    color: (root.pam?.buffer.length ?? 0) > 0
                        ? "#78FFB4"
                        : Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: (root.pam?.buffer.length ?? 0) > 0 ? "#12121A" : Qt.rgba(1, 1, 1, 0.3)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (root.pam?.buffer.length ?? 0) > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            keyTrap.forceActiveFocus();
                            root.pam?.startAuth();
                        }
                    }
                }
            }
        }
    }

    // Active Keyboard Trap
    Item {
        id: keyTrap
        focus: true

        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: event => {
            root.pam?.handleKey(event);
        }
    }
}
