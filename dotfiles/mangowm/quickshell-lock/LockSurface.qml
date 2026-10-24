pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

WlSessionLockSurface {
    id: root

    property WlSessionLock lock
    property PamAuth pam

    color: "#08080C"

    // Keyboard Input Handler Item
    Item {
        anchors.fill: parent
        focus: true

        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: event => {
            root.pam?.handleKey(event);
        }
    }

    // Animated Background Layer (Screensaver effect)
    Item {
        id: bgWrapper
        anchors.fill: parent

        // Gentle breathing scale animation for screensaver feel
        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            NumberAnimation {
                target: bgWrapper
                property: "scale"
                from: 1.0
                to: 1.035
                duration: 16000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: bgWrapper
                property: "scale"
                from: 1.035
                to: 1.0
                duration: 16000
                easing.type: Easing.InOutSine
            }
        }

        Image {
            id: bgImage
            anchors.fill: parent
            source: "file:///tmp/hyprlock/" + (root.screen?.name ?? "default") + ".png"
            fillMode: Image.PreserveAspectCrop
            visible: false
            asynchronous: true

            onStatusChanged: {
                if (status === Image.Error) {
                    source = "file:///home/rtm/.config/mango/images/blackhole.jpg";
                }
            }
        }

        // Hardware-accelerated GPU blur effect
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
            id: orb1
            width: parent.width * 0.42
            height: width
            radius: width / 2
            x: parent.width * 0.15
            y: parent.height * 0.15
            color: Qt.rgba(0.47, 1.0, 0.71, 0.08) // Mint accent #78FFB4
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
            id: orb2
            width: parent.width * 0.38
            height: width
            radius: width / 2
            x: parent.width * 0.50
            y: parent.height * 0.45
            color: Qt.rgba(0.69, 0.33, 0.65, 0.08) // Purple accent #B153A7
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

        // Dark Frosted Vignette Overlay
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.04, 0.07, 0.72) }
                GradientStop { position: 0.5; color: Qt.rgba(0.05, 0.05, 0.08, 0.52) }
                GradientStop { position: 1.0; color: Qt.rgba(0.04, 0.04, 0.07, 0.76) }
            }
        }
    }

    // Space Meteor Shower & Comet Animation (CircuitBoard.qml kept for easy switching)
    MeteorShower {
        anchors.fill: parent
    }

    // Media Card in bottom left with fade-in
    MediaWidget {
        id: mediaCard
        anchors.left: parent.left
        anchors.leftMargin: 48
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48

        opacity: centerCard.opacity
    }

    // Main Center Card with smooth entrance scale/fade
    CenterCard {
        id: centerCard
        anchors.centerIn: parent
        pam: root.pam
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

    // Mouse focus trap
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: forceActiveFocus()
    }
}
