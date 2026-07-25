import QtQuick
import Quickshell
import Quickshell.Widgets
import "Theme.js" as Theme

// One level of the menu tree. Recursively instantiates itself (via Loader)
// for whichever row's submenu is currently open, as a flyout positioned
// beside that row - flipped to the opposite side if it would overflow the
// screen edge.
Rectangle {
    id: level

    // Not `required`: this type loads itself recursively via Loader.source
    // (see below), which constructs the child with no initial properties -
    // required properties would fail at construction time in that case.
    property var items: []
    property size screenSize: Qt.size(0, 0)
    property int depth: 0
    property int openIndex: -1

    signal requestClose

    function closeChild() {
        openIndex = -1;
    }

    function openChildAt(index) {
        openIndex = index;
    }

    width: Math.max(Theme.minWidth, content.implicitWidth + Theme.levelPadding * 2)
    height: content.implicitHeight + Theme.levelPadding * 2
    color: Theme.bg
    radius: Theme.radiusOuter
    border.width: 1
    border.color: Theme.border

    // Swallows clicks on the level's own background/padding so they don't
    // fall through to the full-screen dismiss-on-click backdrop in shell.qml.
    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Column {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.levelPadding
        spacing: Theme.rowSpacing

        Repeater {
            model: level.items

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                property bool hovered: false
                readonly property bool isOpen: level.openIndex === row.index
                readonly property bool highlighted: row.hovered || row.isOpen

                width: content.width
                height: Theme.rowHeight
                radius: Theme.radiusRow
                color: row.highlighted ? Theme.accentBg : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.right: arrow.visible ? arrow.left : parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 6
                    spacing: 8

                    IconImage {
                        id: icon
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        asynchronous: true
                        source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : ""
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.label
                        color: row.highlighted ? Theme.fgSelected : Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }

                Text {
                    id: arrow
                    visible: !!row.modelData.submenu
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"
                    color: row.highlighted ? Theme.fgSelected : Theme.fg
                    font.pixelSize: Theme.fontSize + 2
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        row.hovered = true;
                        if (row.modelData.submenu) {
                            hoverTimer.targetIndex = row.index;
                            hoverTimer.restart();
                        } else {
                            hoverTimer.stop();
                            level.closeChild();
                        }
                    }

                    onExited: {
                        row.hovered = false;
                    }

                    onClicked: {
                        if (row.modelData.submenu) {
                            hoverTimer.stop();
                            level.openChildAt(row.index);
                        } else if (row.modelData.command) {
                            Quickshell.execDetached(["bash", "-c", row.modelData.command]);
                            level.requestClose();
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: hoverTimer
        interval: 220
        property int targetIndex: -1
        onTriggered: {
            if (targetIndex >= 0)
                level.openChildAt(targetIndex);
        }
    }

    readonly property var openSubmenu: (level.openIndex >= 0 && level.items[level.openIndex] !== undefined) ? level.items[level.openIndex].submenu : undefined

    Loader {
        id: childLoader
        active: !!level.openSubmenu

        // A MenuLevel can't instantiate itself via `sourceComponent: MenuLevel {}`
        // (QML rejects that as recursive instantiation), so it's loaded
        // dynamically by URL instead, with properties wired up via Binding
        // below rather than inline construction properties.
        source: "MenuLevel.qml"

        readonly property point levelScenePos: level.mapToItem(null, 0, 0)
        readonly property real fallbackWidth: 220
        readonly property real childWidth: item ? item.width : fallbackWidth
        readonly property bool overflowsRight: (levelScenePos.x + level.width + childWidth) > level.screenSize.width

        x: overflowsRight ? -childWidth : level.width
        y: {
            const rowY = Theme.levelPadding + level.openIndex * (Theme.rowHeight + Theme.rowSpacing);
            const childHeight = item ? item.height : 200;
            const maxY = level.screenSize.height - levelScenePos.y - childHeight - 8;
            return Math.min(rowY, Math.max(8, maxY));
        }

        onLoaded: {
            item.requestClose.connect(level.requestClose);
        }
    }

    Binding {
        target: childLoader.item
        property: "items"
        value: level.openSubmenu || []
        when: childLoader.item !== null
    }

    Binding {
        target: childLoader.item
        property: "screenSize"
        value: level.screenSize
        when: childLoader.item !== null
    }

    Binding {
        target: childLoader.item
        property: "depth"
        value: level.depth + 1
        when: childLoader.item !== null
    }
}
