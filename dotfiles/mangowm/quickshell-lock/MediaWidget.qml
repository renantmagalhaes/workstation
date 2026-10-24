pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: root

    readonly property var players: Mpris.players?.values ?? []
    readonly property var activePlayer: {
        for (let i = 0; i < players.length; i++) {
            if (players[i]?.playbackState === MprisPlaybackState.Playing)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle.length > 0)

    visible: hasMedia
    implicitWidth: 380
    implicitHeight: 88

    radius: 24
    color: Qt.rgba(0.08, 0.08, 0.12, 0.65)
    border.color: Qt.rgba(1, 1, 1, 0.10)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        // Album Art Thumbnail
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            radius: 14
            color: Qt.rgba(0.15, 0.15, 0.22, 0.8)
            clip: true

            Image {
                anchors.fill: parent
                source: root.activePlayer?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                color: Qt.rgba(1, 1, 1, 0.4)
                visible: !root.activePlayer?.trackArtUrl
            }
        }

        // Title & Artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: root.activePlayer?.trackTitle || "No media"
                font.family: "Inter, Noto Sans, sans-serif"
                font.pixelSize: 15
                font.bold: true
                color: "#FFFFFF"
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.activePlayer?.trackArtist || "Unknown artist"
                font.family: "Inter, Noto Sans, sans-serif"
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.65)
                elide: Text.ElideRight
            }
        }

        // Controls
        RowLayout {
            spacing: 6

            // Prev
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: prevArea.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activePlayer?.previous()
                }
            }

            // Play / Pause
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.90)

                Text {
                    anchors.centerIn: parent
                    text: (root.activePlayer?.playbackState === MprisPlaybackState.Playing) ? "" : ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: "#12121A"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activePlayer?.togglePlaying()
                }
            }

            // Next
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: nextArea.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activePlayer?.next()
                }
            }
        }
    }
}
