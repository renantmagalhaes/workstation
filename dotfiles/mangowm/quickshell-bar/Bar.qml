import QtQuick
import Quickshell
import Quickshell.Wayland
import "Config"

// One island per monitor, plus its dismiss catcher.
//
// Both are top-level layer surfaces, so they live side by side in a Scope
// rather than nested -- a PanelWindow cannot be a visual child of another
// window. The open page is owned here because both surfaces depend on it.
Scope {
    id: root

    required property var modelData

    // "" when collapsed, otherwise the name of the open page.
    property string page: ""
    readonly property bool expanded: page !== ""

    // The island. A fixed, oversized, fully transparent canvas sized to the
    // largest state the island can reach; only the inner surface morphs, so the
    // compositor never resizes or re-centres a surface mid-animation. `mask`
    // narrows input back to the visible pill so the rest stays click-through.
    PanelWindow {
        screen: root.modelData
        color: "transparent"

        // Overlay, not Top: the island must stay visible over fullscreen
        // windows, and it has to outrank the catcher below. Surfaces in the
        // same layer stack in creation order, which would otherwise let the
        // catcher swallow clicks meant for the expanded page.
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-island"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Theme.topMargin + Theme.islandHeight + Theme.panelGap + Theme.tailHeight + Theme.maxPanelHeight + Theme.glowPad

        // Reserve only the collapsed pill's strip, never the expanded panel, so
        // windows keep their geometry when the island opens.
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Theme.topMargin + Theme.islandHeight + Theme.bottomGap

        // Mask the pill and the panel as two separate rectangles. Masking their
        // bounding box instead would swallow clicks in the gap between them and
        // in the empty space either side of the panel.
        mask: Region {
            item: island.pillItem

            Region {
                item: root.expanded ? island.panelItem : null
            }
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

    // Click-anywhere-to-dismiss. Mapped only while a page is open, so nothing
    // full-screen sits on the Top layer at rest.
    PanelWindow {
        screen: root.modelData
        visible: root.expanded
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-island-dismiss"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        // Anchoring all four edges is not enough to size a layer surface --
        // without an explicit size it maps as 0x0 and silently swallows
        // nothing. Take the dimensions straight from the output.
        implicitWidth: root.modelData.width
        implicitHeight: root.modelData.height

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressed: root.page = ""
        }
    }
}
