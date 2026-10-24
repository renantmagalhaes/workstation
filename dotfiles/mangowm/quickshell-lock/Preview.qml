pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell

ShellRoot {
    id: root

    FloatingWindow {
        id: win
        title: "Lockscreen Preview (Safe Mode - Esc to close)"
        width: 1100
        height: 700
        visible: true
        color: "#08080C"

        PamAuth {
            id: pam

            onAuthenticated: {
                console.log("Password verified successfully in preview!");
                statusText.text = "✓ Password verified successfully!";
                statusText.color = "#78FFB4";
            }

            onFailedAuth: msg => {
                console.log("Authentication failed in preview:", msg);
                statusText.text = "✗ " + msg;
                statusText.color = "#FF5555";
            }
        }

        // Animated Background Layer (Screensaver effect)
        Item {
            id: bgWrapper
            anchors.fill: parent

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                NumberAnimation { target: bgWrapper; property: "scale"; from: 1.0; to: 1.035; duration: 16000; easing.type: Easing.InOutSine }
                NumberAnimation { target: bgWrapper; property: "scale"; from: 1.035; to: 1.0; duration: 16000; easing.type: Easing.InOutSine }
            }

            Image {
                id: bgImage
                anchors.fill: parent
                source: "file:///tmp/hyprlock/HDMI-A-1.png"
                fillMode: Image.PreserveAspectCrop
                visible: false
                asynchronous: true

                onStatusChanged: {
                    if (status === Image.Error) {
                        source = "file:///home/rtm/.config/mango/images/blackhole.jpg";
                    }
                }
            }

            MultiEffect {
                id: blurEffect
                anchors.fill: bgImage
                source: bgImage
                blurEnabled: true
                blur: 1.0
                blurMax: 64
                blurMultiplier: 1.35
                brightness: -0.14
                contrast: 0.10
                saturation: 0.18
            }

            // Ambient Floating Aurora Orbs
            Rectangle {
                width: parent.width * 0.42
                height: width
                radius: width / 2
                x: parent.width * 0.15
                y: parent.height * 0.15
                color: Qt.rgba(0.47, 1.0, 0.71, 0.08)
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation { from: bgWrapper.width * 0.12; to: bgWrapper.width * 0.32; duration: 20000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: bgWrapper.width * 0.32; to: bgWrapper.width * 0.12; duration: 20000; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation { from: bgWrapper.height * 0.12; to: bgWrapper.height * 0.28; duration: 16000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: bgWrapper.height * 0.28; to: bgWrapper.height * 0.12; duration: 16000; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                width: parent.width * 0.38
                height: width
                radius: width / 2
                x: parent.width * 0.50
                y: parent.height * 0.45
                color: Qt.rgba(0.69, 0.33, 0.65, 0.08)
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation { from: bgWrapper.width * 0.52; to: bgWrapper.width * 0.35; duration: 22000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: bgWrapper.width * 0.35; to: bgWrapper.width * 0.52; duration: 22000; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation { from: bgWrapper.height * 0.45; to: bgWrapper.height * 0.25; duration: 18000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: bgWrapper.height * 0.25; to: bgWrapper.height * 0.45; duration: 18000; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.04, 0.07, 0.72) }
                    GradientStop { position: 0.5; color: Qt.rgba(0.05, 0.05, 0.08, 0.52) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.04, 0.04, 0.07, 0.76) }
                }
            }
        }

        // Media widget in bottom left
        MediaWidget {
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 32
            opacity: centerCard.opacity
        }

        // Center card with clock, avatar, password
        CenterCard {
            id: centerCard
            anchors.centerIn: parent
            pam: pam
            username: "rtm"

            scale: 0.94
            opacity: 0

            Component.onCompleted: entranceAnim.start()

            ParallelAnimation {
                id: entranceAnim
                NumberAnimation { target: centerCard; property: "scale"; to: 1.0; duration: 450; easing.type: Easing.OutBack }
                NumberAnimation { target: centerCard; property: "opacity"; to: 1.0; duration: 350; easing.type: Easing.OutCubic }
            }
        }

        // Status banner at top
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: statusText.implicitWidth + 32
            height: 36
            radius: 18
            color: Qt.rgba(0.1, 0.1, 0.15, 0.85)
            border.color: Qt.rgba(1, 1, 1, 0.15)

            Text {
                id: statusText
                anchors.centerIn: parent
                text: "Preview Mode — Type password + Enter to test PAM (Esc to close)"
                font.family: "Inter, sans-serif"
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.6)
            }
        }

        Shortcut {
            sequence: "Escape"
            onActivated: Quickshell.process.exit(0)
        }
    }
}
