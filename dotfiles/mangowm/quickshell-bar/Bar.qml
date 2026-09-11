import QtQuick
import Quickshell
import Quickshell.Wayland
import "Config"

// One island per monitor.
//
// The surface covers the whole output and is fully transparent; `mask` narrows
// input down to just the visible pill, so everything else stays click-through.
// When a page opens the mask widens to the entire output, and the dismiss area
// underneath the island picks up any click that misses the panel.
//
// This used to be two surfaces, with a separate full-screen catcher. That
// cannot work here: the island has to sit on the Top layer (mango draws a
// fullscreen client above Top but below Overlay, which is what lets a
// maximised window cover the bar), and two surfaces on the *same* layer cannot
// be reliably ordered -- the catcher maps later than the island, so it always
// ended up on top and swallowed clicks meant for the panel. Inside one window,
// declaration order settles it for good.
Scope {
    id: root

    required property var modelData

    // "" when collapsed, otherwise the name of the open page.
    property string page: ""
    readonly property bool expanded: page !== ""

    PanelWindow {
        id: barWindow

        screen: root.modelData
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-island"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: root.modelData.height

        // Reserve only the collapsed pill's strip. The surface being full
        // height does not widen the reservation, so windows keep their
        // geometry whether or not a page is open.
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Theme.topMargin + Theme.islandHeight + Theme.bottomGap

        mask: Region {
            // Collapsed: only the pill is clickable. Expanded: the whole
            // output, so a click anywhere lands either on the panel or on the
            // dismiss area below it.
            item: root.expanded ? null : island.pillItem
            width: root.expanded ? barWindow.width : 0
            height: root.expanded ? barWindow.height : 0
        }

        // Declared before the island, so the island and its panel sit above it
        // and take their own clicks first.
        MouseArea {
            anchors.fill: parent
            enabled: root.expanded
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressed: root.page = ""
        }

        Island {
            id: island

            monitorName: root.modelData.name
            page: root.page
            onRequestToggle: name => root.page = root.page === name ? "" : name

            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.topMargin
        }
    }
}
