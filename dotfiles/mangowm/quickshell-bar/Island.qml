import QtQuick
import "Config"
import "Modules"

// The island itself: a single rounded surface that morphs between a collapsed
// pill and an expanded panel.
//
// The collapsed row stays mounted and visible in both states, so opening a page
// reads as the pill *growing downward* rather than swapping content. Width and
// height are plain derived bindings with Behaviors on them -- there is no
// imperative animation anywhere.
Item {
    id: root

    required property string monitorName

    // "" | "calendar" | "volume". Owned by Bar, which also drives the dismiss
    // catcher from it; the island only asks for changes.
    property string page: ""
    readonly property bool expanded: page !== ""

    signal requestToggle(string name)

    implicitWidth: surface.width
    implicitHeight: surface.height

    Rectangle {
        id: surface

        readonly property int pageWidth: root.page === "calendar" ? Theme.calendarWidth : root.page === "volume" ? Theme.volumePageWidth : 0
        readonly property int pageHeight: root.page === "calendar" ? Theme.calendarHeight : root.page === "volume" ? Theme.volumePageHeight : 0

        width: Math.max(collapsedRow.implicitWidth + Theme.islandPadH * 2, pageWidth)
        height: Theme.islandHeight + pageHeight
        radius: root.expanded ? Theme.panelRadius : Theme.islandRadius
        color: Theme.islandBg
        clip: true

        border.width: 1
        border.color: Theme.islandBorder

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
        Behavior on radius {
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
                leftMargin: parent.radius * 0.6
                rightMargin: parent.radius * 0.6
            }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#26FFFFFF" }
                GradientStop { position: 1.0; color: "transparent" }
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

            Separator {
                visible: tray.hasItems
            }

            Tray {
                id: tray
                anchors.verticalCenter: parent.verticalCenter
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
            sourceComponent: root.page === "calendar" ? calendarPage : root.page === "volume" ? volumePage : null

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
    }
}
