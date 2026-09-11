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
    readonly property bool showActions: hover.hovered && present

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

    implicitWidth: present ? (showActions ? actionRow.implicitWidth : titleRow.implicitWidth) + Theme.capsulePadH : 0
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
