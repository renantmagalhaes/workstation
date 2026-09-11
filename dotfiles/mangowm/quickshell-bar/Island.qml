import QtQuick
import "Config"
import "Modules"
import "Widgets"

// The island itself: a single squircle surface that morphs between a collapsed
// pill and an expanded panel.
//
// The collapsed row stays mounted and visible in both states, so opening a page
// reads as the pill *growing downward* rather than swapping content. Width and
// height are plain derived bindings with Behaviors on them -- there is no
// imperative animation anywhere.
//
// Modules that have nothing to say (no focused window, no media player, an
// empty tray) collapse to zero width and the island shrinks around them.
Item {
    id: root

    required property string monitorName

    // "" | "calendar" | "volume" | "media" | "system" | "session". Owned by Bar,
    // which also drives the dismiss catcher from it; the island only asks.
    property string page: ""
    readonly property bool expanded: page !== ""

    signal requestToggle(string name)

    implicitWidth: surface.width
    implicitHeight: surface.height

    Item {
        id: surface

        readonly property int pageWidth: {
            switch (root.page) {
            case "calendar":
                return Theme.calendarWidth;
            case "volume":
                return Theme.volumePageWidth;
            case "media":
                return Theme.mediaPageWidth;
            case "system":
                return Theme.systemPageWidth;
            case "session":
                return Theme.sessionPageWidth;
            default:
                return 0;
            }
        }

        readonly property int pageHeight: {
            switch (root.page) {
            case "calendar":
                return Theme.calendarHeight;
            case "volume":
                return Theme.volumePageHeight;
            case "media":
                return Theme.mediaPageHeight;
            case "system":
                return Theme.systemPageHeight;
            case "session":
                return Theme.sessionPageHeight;
            default:
                return 0;
            }
        }

        // Not readonly: a Behavior can only animate a writable property.
        property real cornerRadius: root.expanded ? Theme.panelRadius : Theme.islandRadius

        width: Math.max(collapsedRow.implicitWidth + Theme.islandPadH * 2, pageWidth)
        height: Theme.islandHeight + pageHeight

        // Rectangular clip. The squircle sits inside these bounds and content is
        // inset by padding, so it never reaches the corners -- masking to the
        // actual curve would cost a render pass for no visible difference.
        clip: true

        Squircle {
            anchors.fill: parent
            fillColor: Theme.islandBg
            borderColor: Theme.islandBorder
            borderWidth: 1
            radius: surface.cornerRadius
            exponent: Theme.squircleExponent
        }

        Behavior on width {
            NumberAnimation {
                duration: Theme.durIsland
                easing.type: Easing.OutBack
                easing.overshoot: Theme.overshoot
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.durIsland
                easing.type: Easing.OutBack
                easing.overshoot: Theme.overshoot
            }
        }
        Behavior on cornerRadius {
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutCubic
            }
        }

        // Faint top highlight -- reads as a lit bevel and keeps the pill from
        // looking like a flat black hole on dark wallpapers.
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 1
                leftMargin: surface.cornerRadius * 0.8
                rightMargin: surface.cornerRadius * 0.8
            }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: "#26FFFFFF"
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        // ---- Collapsed row (always mounted) --------------------------------
        Row {
            id: collapsedRow

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            height: Theme.islandHeight
            spacing: Theme.sectionSpacing

            Workspaces {
                monitorName: root.monitorName
                anchors.verticalCenter: parent.verticalCenter
            }

            Separator {
                visible: windowTitle.present
            }

            WindowTitle {
                id: windowTitle
                anchors.verticalCenter: parent.verticalCenter
            }

            Separator {
                visible: mediaChip.present
            }

            MediaChip {
                id: mediaChip
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "media"
                onActivated: root.requestToggle("media")
            }

            Separator {}

            Clock {
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "calendar"
                onActivated: root.requestToggle("calendar")
            }

            Separator {}

            Volume {
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "volume"
                onActivated: root.requestToggle("volume")
            }

            StatusChip {
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "system"
                onActivated: root.requestToggle("system")
            }

            NotifButton {
                anchors.verticalCenter: parent.verticalCenter
            }

            Separator {
                visible: tray.hasItems
            }

            Tray {
                id: tray
                anchors.verticalCenter: parent.verticalCenter
            }

            Separator {}

            PowerButton {
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "session"
                onActivated: root.requestToggle("session")
            }
        }

        // ---- Expanded page -------------------------------------------------
        Loader {
            id: pageLoader

            anchors {
                top: parent.top
                topMargin: Theme.islandHeight
                horizontalCenter: parent.horizontalCenter
            }
            // Pages fill the surface: the pill is usually wider than a page's
            // natural size, and centring a narrow page inside it leaves dead
            // gutters. pageWidth only acts as a lower bound on the surface.
            width: surface.width
            height: surface.pageHeight

            active: root.page !== ""
            sourceComponent: {
                switch (root.page) {
                case "calendar":
                    return calendarPage;
                case "volume":
                    return volumePage;
                case "media":
                    return mediaPage;
                case "system":
                    return systemPage;
                case "session":
                    return sessionPage;
                default:
                    return null;
                }
            }

            // Fade the content in only once the surface has most of its room,
            // so text never reflows inside a still-growing box.
            opacity: root.expanded ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Component {
            id: calendarPage
            CalendarPage {}
        }

        Component {
            id: volumePage
            VolumePage {}
        }

        Component {
            id: mediaPage
            MediaPage {}
        }

        Component {
            id: systemPage
            SystemPage {}
        }

        Component {
            id: sessionPage
            SessionPage {}
        }
    }
}
