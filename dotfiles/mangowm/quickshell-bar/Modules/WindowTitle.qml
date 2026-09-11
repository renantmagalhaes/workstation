import QtQuick
import Quickshell
import Quickshell.Widgets
import "../Config"
import "../Services"
import "../Widgets"

// Focused window: app icon + title, which morphs into the window action
// buttons on hover. Replaces waybar's window-capsule plus the sys-actions
// capsule, and ties those actions to the window they act on.
Item {
    id: root

    readonly property bool present: Mango.hasWindow

    // Hover intent, not raw hover: sweeping the pointer across the bar used to
    // flash the actions on and off. Showing needs a deliberate pause, and
    // leaving keeps them a moment longer so crossing a gap doesn't drop them.
    property bool showActions: false

    Timer {
        id: revealTimer
        interval: 350
        onTriggered: root.showActions = true
    }

    Timer {
        id: concealTimer
        interval: 220
        onTriggered: root.showActions = false
    }

    onPresentChanged: {
        if (present) return;
        revealTimer.stop();
        concealTimer.stop();
        showActions = false;
    }

    // Resolve a real themed icon from the appid instead of a hand-maintained
    // glyph table. Mango appids are often reverse-DNS (com.stremio.Stremio),
    // so fall back through the desktop entry and the trailing segment.
    // DesktopEntries populates asynchronously -- it is still empty for the
    // first moments of the session -- and heuristicLookup() is a plain function
    // call that no binding can track. So refresh explicitly whenever either
    // input changes, otherwise the icon is permanently missing for any app
    // whose appid differs from its icon name (e.g. vivaldi-stable -> vivaldi).
    property var entry: null

    function updateEntry() {
        const appId = Mango.windowAppId;
        entry = appId ? DesktopEntries.heuristicLookup(appId) : null;
    }

    Component.onCompleted: updateEntry()

    Connections {
        target: Mango
        function onWindowAppIdChanged() {
            root.updateEntry();
        }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root.updateEntry();
        }
    }

    readonly property string appName: entry?.name || Mango.windowAppId

    readonly property string iconSource: {
        const appId = Mango.windowAppId;
        if (!appId) return "";

        if (entry?.icon) {
            const themed = Quickshell.iconPath(entry.icon, true);
            if (themed) return themed;
        }

        const direct = Quickshell.iconPath(appId, true);
        if (direct) return direct;

        const lower = appId.toLowerCase();
        const tail = lower.split(".").pop();
        return Quickshell.iconPath(lower, true) || Quickshell.iconPath(tail, true) || "";
    }

    // Most apps suffix the window title with their own name; drop it so the
    // bar doesn't read "Foo — Vivaldi  Vivaldi".
    readonly property string displayTitle: {
        const title = Mango.windowTitle;
        if (!title) return "";
        const name = root.appName;
        if (name && title.length > name.length && title.endsWith(name))
            return title.slice(0, title.length - name.length).replace(/[\s\-—|]+$/, "");
        return title;
    }

    // Collapses to the action buttons on hover. The pill is centre-aligned, so
    // shrinking here leaves this module's own centre where it was and only
    // pulls its edges in -- which is what makes the stable hover zone below
    // work.
    readonly property real restWidth: titleRow.implicitWidth + Theme.capsulePadH
    readonly property real activeWidth: actionRow.implicitWidth + Theme.capsulePadH

    implicitWidth: present ? (showActions ? activeWidth : restWidth) : 0
    implicitHeight: Theme.islandHeight
    visible: present

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durNormal
            easing.type: Easing.OutCubic
        }
    }

    // HoverHandler rather than a MouseArea: it keeps reporting hovered while
    // the pointer is over the action buttons, so they don't flicker away as
    // soon as you reach for them.
    // Hover is judged against the widest state, not the current one. Otherwise
    // revealing the buttons shrinks the module out from under the pointer, which
    // conceals them, which grows it back -- a slow blink instead of a fast one.
    // This zone is centred on the module and never changes size, so it stays
    // put in screen space no matter which face is showing.
    readonly property bool pointerNear: hover.hovered || zoneHover.hovered

    onPointerNearChanged: {
        if (pointerNear && present) {
            concealTimer.stop();
            revealTimer.restart();
        } else {
            revealTimer.stop();
            concealTimer.restart();
        }
    }

    Item {
        id: hoverZone

        anchors.centerIn: parent
        width: Math.max(root.restWidth, root.activeWidth)
        height: parent.height

        HoverHandler {
            id: zoneHover
        }
    }

    // Kept as well: a MouseArea on a child button blocks hover from reaching a
    // sibling's handler, so the zone alone would drop out over the buttons.
    HoverHandler {
        id: hover
    }

    Row {
        id: titleRow

        anchors.centerIn: parent
        spacing: 6
        opacity: root.showActions ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSnappy
            }
        }

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.iconSize + 2
            height: Theme.iconSize + 2
            source: root.iconSource
            asynchronous: true
            smooth: true
            mipmap: true
            visible: status === Image.Ready
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 200)
            elide: Text.ElideRight
            text: root.displayTitle
            color: Theme.fg
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }

    Row {
        id: actionRow

        anchors.centerIn: parent
        spacing: 2
        opacity: root.showActions ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSnappy
            }
        }

        IconButton {
            glyph: Mango.windowFullscreen ? "󰊔" : "󰊓"
            accent: "#F1C40F"
            onActivated: Mango.toggleFullscreen()
        }

        IconButton {
            glyph: "󰍺"
            accent: "#2ECC71"
            onActivated: Mango.moveToNextMonitor()
        }

        IconButton {
            glyph: "󰅙"
            accent: Theme.urgent
            onActivated: Mango.killActive()
        }
    }
}
