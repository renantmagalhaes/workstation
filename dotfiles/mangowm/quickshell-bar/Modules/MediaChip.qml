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
Item {
    id: root

    property bool active: false
    signal activated

    readonly property bool present: Media.hasPlayer
    readonly property int artSize: Theme.islandHeight - 12

    implicitWidth: present ? row.implicitWidth + Theme.capsulePadH * 2 : 0
    implicitHeight: Theme.islandHeight
    visible: present

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

    Row {
        id: row

        anchors.centerIn: parent
        // Close to the gap the chip leaves to its neighbouring separators
        // (capsulePadH + sectionSpacing), so art and meter read as evenly
        // spaced with everything around them rather than crammed together.
        spacing: 8

        // Artwork leads: it is the thing that identifies what is playing at a
        // glance, and it anchors the chip against the neighbouring modules.
        // Only when there is artwork -- an empty placeholder box next to the
        // meter would just be noise.
        ClippingRectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: root.artSize
            height: root.artSize
            radius: 5
            color: Theme.tint
            visible: Media.artUrl !== ""

            Image {
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                // Cover art is full size; without these it gets decoded at
                // original resolution and naively downscaled to ~20px, which
                // turns detailed artwork to mush.
                mipmap: true
                sourceSize: Qt.size(root.artSize * 3, root.artSize * 3)
                visible: status === Image.Ready
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
