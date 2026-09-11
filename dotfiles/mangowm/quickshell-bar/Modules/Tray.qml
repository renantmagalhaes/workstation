import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../Config"

Item {
    id: root

    readonly property var items: SystemTray.items.values
    readonly property bool hasItems: items.length > 0

    implicitWidth: hasItems ? row.implicitWidth + Theme.capsulePadH : 0
    implicitHeight: Theme.islandHeight
    visible: hasItems

    // StatusNotifierItem icons arrive in several shapes: a plain icon name, an
    // absolute path, or KDE's "name?path=/dir" form that has to be rebuilt into
    // a file:// URL by hand.
    function iconSource(item) {
        const icon = item?.icon;
        if (typeof icon !== "string" || icon === "") return "";

        if (icon.includes("?path=")) {
            const parts = icon.split("?path=");
            if (parts.length !== 2) return icon;
            const name = parts[0];
            const dir = parts[1];
            return `file://${dir}/${name.substring(name.lastIndexOf("/") + 1)}`;
        }

        if (icon.startsWith("/")) return `file://${icon}`;
        return icon;
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durIsland
            easing.type: Easing.OutCubic
        }
    }

    QsMenuAnchor {
        id: trayMenu
        anchor.window: root.QsWindow?.window ?? null
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: root.items

            delegate: Item {
                id: entry

                required property var modelData

                width: Theme.islandHeight - 8
                height: Theme.islandHeight - 8
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.chipRadius
                    color: area.containsMouse ? Theme.hover : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durSnappy
                        }
                    }
                }

                IconImage {
                    id: image

                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: root.iconSource(entry.modelData)
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    visible: status === Image.Ready
                }

                // Some apps ship a broken or empty icon; fall back to an initial
                // rather than rendering an invisible, unclickable-looking gap.
                Text {
                    anchors.centerIn: parent
                    visible: !image.visible
                    text: (entry.modelData?.id ?? "?").charAt(0).toUpperCase()
                    color: Theme.fgDim
                    font.family: Theme.fontFamily; renderType: Text.QtRendering
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: event => {
                        const item = entry.modelData;
                        if (!item) return;

                        const wantsMenu = event.button === Qt.RightButton || item.onlyMenu;

                        if (wantsMenu) {
                            if (!item.hasMenu) return;
                            const origin = entry.mapToItem(null, 0, entry.height);
                            trayMenu.menu = item.menu;
                            trayMenu.anchor.rect = Qt.rect(origin.x, origin.y + 6, entry.width, 1);
                            trayMenu.open();
                            return;
                        }

                        item.activate();
                    }
                }
            }
        }
    }
}
