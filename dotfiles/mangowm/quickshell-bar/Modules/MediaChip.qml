import QtQuick
import Quickshell.Widgets
import "../Config"
import "../Services"
import "../Widgets"

// Deliberately minimal: a level meter marking this as an audio source, plus
// the cover art when the player publishes any.
//
// Title, artist, seek bar and player picker all live in the media page. A
// scrolling title here made this the widest module in the bar, permanently, for
// something you read once when the track changes -- so the pill only says
// "something is playing, here is its cover" and the detail is one click away.
//
// Left click opens the page, right click is play/pause; there is no transport
// button taking up room for an action you rarely need mid-glance.
//
// When no track is loaded (player idle or no player registered), the chip
// collapses to a single dimmed music-note glyph so the picker remains reachable.
Item {
    id: root

    property bool active: false
    signal activated

    // True when there is something meaningful to show -- a playing or paused
    // track. False when a player is registered but idle (no track loaded), or
    // when no player exists at all.
    readonly property bool hasMedia: Media.playing || Media.title !== "" || Media.artUrl !== ""
    readonly property bool present: hasMedia
    readonly property int artSize: Theme.islandHeight - 12

    // Idle: just wide enough for the single music-note glyph.
    // Active: expands to fit art + equalizer.
    implicitWidth: hasMedia ? row.implicitWidth + Theme.capsulePadH * 2 : Theme.islandHeight - 6
    implicitHeight: Theme.islandHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durIsland
            easing.type: Easing.OutCubic
        }
    }

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

    // Idle state: no track loaded. Dimmed glyph keeps the chip tappable so
    // the player picker is always reachable.
    Text {
        anchors.centerIn: parent
        visible: !root.hasMedia
        text: "󰎈"
        color: Theme.fgFaint
        font.family: Theme.iconFamily
        renderType: Text.QtRendering
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.durSnappy
            }
        }
    }

    // Active state: player has a track (playing or paused).
    Row {
        id: row

        anchors.centerIn: parent
        spacing: 8
        visible: root.hasMedia

        // Artwork leads: it is the thing that identifies what is playing at a
        // glance, and it anchors the chip against the neighbouring modules.
        // Only when there is artwork -- an empty placeholder box next to the
        // meter would just be noise.
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: root.artSize
            height: root.artSize
            visible: Media.artUrl !== ""

            // Ambient breathing glow behind cover art when playing
            Rectangle {
                id: artGlow
                anchors.centerIn: parent
                width: parent.width + 4
                height: parent.height + 4
                radius: 7
                color: Theme.accent
                opacity: Media.playing ? glowAnim.glowVal : 0.0
                visible: opacity > 0

                QtObject {
                    id: glowAnim
                    property real glowVal: 0.35
                    SequentialAnimation on glowVal {
                        running: Media.playing
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.65; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.20; duration: 1500; easing.type: Easing.InOutSine }
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
            }

            ClippingRectangle {
                anchors.fill: parent
                radius: 5
                color: Theme.tint

                Image {
                    id: coverImg
                    anchors.fill: parent
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    sourceSize: Qt.size(root.artSize * 3, root.artSize * 3)
                    visible: status === Image.Ready

                    scale: status === Image.Ready ? 1.0 : 0.82
                    opacity: status === Image.Ready ? 1.0 : 0.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // Marks the chip as an audio source, and carries the state cue now
        // that the transport button is gone: moving while playing, flat and
        // dimmed while paused.
        Equalizer {
            anchors.verticalCenter: parent.verticalCenter
            active: Media.playing
            color: Media.playing ? Theme.fg : Theme.fgDim
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                Media.toggle();
            else
                root.activated();
        }

        onWheel: wheel => {
            wheel.accepted = true;
            if (wheel.angleDelta.y > 0)
                Media.previous();
            else
                Media.next();
        }
    }
}
