import QtQuick
import "Config"
import "Modules"
import "Widgets"

// The island: a squircle pill, plus a detached popover panel that points back
// at whichever chip opened it.
//
// The panel is a separate surface with a gap and a speech-bubble tail rather
// than an extension of the pill -- glued to the bar it read as one shapeless
// blob, and nothing indicated which chip it belonged to.
//
// Modules that have nothing to say (no focused window, no media player, an
// empty tray) collapse to zero width and the pill shrinks around them.
Item {
    id: root

    required property string monitorName

    // "" | "calendar" | "volume" | "media" | "system" | "session". Owned by Bar,
    // which also drives the dismiss catcher from it; the island only asks.
    property string page: ""
    readonly property bool expanded: page !== ""

    signal requestToggle(string name)

    // Exposed so the window can mask input to exactly these two rectangles
    // instead of their bounding box.
    readonly property Item pillItem: pill
    readonly property Item panelItem: panel

    // Latched panel size: kept at the last open page's dimensions so collapsing
    // fades the panel out at its own size instead of animating it to nothing.
    property int panelW: Theme.calendarWidth
    property int panelH: Theme.calendarHeight

    readonly property Item anchorItem: anchorItemFor(page)

    // Centre of the chip that opened the panel, in root coordinates. This has
    // to stay a live binding rather than a value latched on open: the row
    // relayouts underneath an open panel whenever a chip appears or goes away
    // (media starting, tray icon arriving), which shifts every chip after it.
    readonly property real anchorCenterX: {
        if (!anchorItem) return pill.width / 2;
        // mapToItem() is not reactive, so read the geometry it depends on to
        // give this binding something to track.
        const track = anchorItem.x + anchorItem.width + collapsedRow.x + collapsedRow.width + pill.x + pill.width;
        return track >= 0 ? anchorItem.mapToItem(root, anchorItem.width / 2, 0).x : 0;
    }

    // A page may report a taller natural height than its Theme entry (the audio
    // page grows with the number of devices); the Theme value is the floor.
    readonly property int contentHeight: Math.max(panelH, pageLoader.item?.implicitHeight ?? 0)

    function pageWidthFor(name) {
        switch (name) {
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
        }
        return Theme.calendarWidth;
    }

    function pageHeightFor(name) {
        switch (name) {
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
        }
        return Theme.calendarHeight;
    }

    function anchorItemFor(name) {
        switch (name) {
        case "calendar":
            return clockModule;
        case "volume":
            return volumeModule;
        case "media":
            return mediaChip;
        case "system":
            return statusChip;
        case "session":
            return powerButton;
        }
        return null;
    }

    // True only while swapping one open page for another. Updated a tick late,
    // so that during the change itself it still describes the *previous* state
    // -- which is exactly what the geometry Behaviors need in order to decide
    // between "appear here" and "morph to here".
    property string previousPage: ""
    readonly property bool morphing: page !== "" && previousPage !== ""

    onPageChanged: {
        if (page !== "") {
            panelW = pageWidthFor(page);
            panelH = pageHeightFor(page);
        }
        Qt.callLater(() => root.previousPage = root.page);
    }

    implicitWidth: Math.max(pill.width, panelW)
    implicitHeight: pill.height + (expanded ? Theme.panelGap + Theme.tailHeight + contentHeight : 0)

    // ---- The pill ----------------------------------------------------------
    Item {
        id: pill

        x: (root.width - width) / 2
        y: 0
        width: collapsedRow.implicitWidth + Theme.islandPadH * 2
        height: Theme.islandHeight
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.durIsland
                easing.type: Easing.OutBack
                easing.overshoot: Theme.overshoot
            }
        }

        Squircle {
            anchors.fill: parent
            fillColor: Theme.islandBg
            borderColor: Theme.islandBorder
            borderWidth: 1
            radius: Theme.islandRadius
            exponent: Theme.squircleExponent
        }

        // Faint top highlight -- reads as a lit bevel and keeps the pill from
        // looking like a flat black hole on dark wallpapers.
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 1
                leftMargin: Theme.islandRadius * 0.8
                rightMargin: Theme.islandRadius * 0.8
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

        Row {
            id: collapsedRow

            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.islandHeight
            spacing: Theme.sectionSpacing

            Workspaces {
                monitorName: root.monitorName
                anchors.verticalCenter: parent.verticalCenter
            }

            // Sits with the workspace dots rather than behind a separator:
            // both are about what is on this tag.
            ScrollArrows {
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
                id: clockModule
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "calendar"
                onActivated: root.requestToggle("calendar")
            }

            Separator {}

            Volume {
                id: volumeModule
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "volume"
                onActivated: root.requestToggle("volume")
            }

            StatusChip {
                id: statusChip
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
                id: powerButton
                anchors.verticalCenter: parent.verticalCenter
                active: root.page === "session"
                onActivated: root.requestToggle("session")
            }
        }
    }

    // ---- The detached panel ------------------------------------------------
    Item {
        id: panel

        width: root.panelW
        height: Theme.tailHeight + root.contentHeight
        // Centre on the chip that opened it, clamped inside the pill's span.
        x: Math.max(0, Math.min(root.width - width, root.anchorCenterX - width / 2))
        y: pill.height + Theme.panelGap

        visible: opacity > 0
        opacity: root.expanded ? 1 : 0

        // Pops out of its own tail rather than scaling from the panel's top
        // centre, so it reads as emerging from the chip that opened it.
        property real popScale: root.expanded ? 1 : 0.9

        transform: Scale {
            origin.x: root.anchorCenterX - panel.x
            origin.y: 0
            xScale: panel.popScale
            yScale: panel.popScale
        }

        // Geometry is only animated when morphing between two open pages.
        // Animating it on open made the panel visibly travel across the bar
        // from wherever it last sat; it should appear where it belongs.
        Behavior on width {
            enabled: root.morphing
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            enabled: root.morphing
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on x {
            enabled: root.morphing
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSnappy
            }
        }
        Behavior on popScale {
            NumberAnimation {
                duration: Theme.durNormal
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
        }

        Squircle {
            anchors.fill: parent
            fillColor: Theme.islandBg
            borderColor: Theme.islandBorder
            borderWidth: 1
            radius: Theme.panelRadius
            exponent: Theme.squircleExponent
            tailHeight: Theme.tailHeight
            tailWidth: Theme.tailWidth
            tailX: root.anchorCenterX - panel.x
        }

        Loader {
            id: pageLoader

            y: Theme.tailHeight
            width: parent.width
            height: root.contentHeight

            active: root.expanded
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
                }
                return null;
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
