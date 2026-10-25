pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../Config"
import "../Services"

PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: WallpaperManager.open

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-wallpapers"
    WlrLayershell.keyboardFocus: (WallpaperManager.open && (WallpaperManager.activeMonitorName === monName)) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string monName: win.screen?.name ?? "DP-1"
    readonly property bool isTargetMonitor: WallpaperManager.activeMonitorName === monName

    // Click outside dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: WallpaperManager.closePicker()
    }

    // Centered Card Container
    Item {
        id: cardContainer
        anchors.centerIn: parent
        width: 860
        height: 560
        visible: win.isTargetMonitor

        // Animation
        scale: WallpaperManager.open ? 1.0 : 0.95
        opacity: WallpaperManager.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: WallpaperManager.open ? 240 : 160
                easing.type: WallpaperManager.open ? Easing.OutBack : Easing.OutQuad
                easing.overshoot: 1.06
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: WallpaperManager.open ? 180 : 140
                easing.type: Easing.OutCubic
            }
        }

        // Panel card implementation
        Rectangle {
            id: panelCard
            anchors.fill: parent
            radius: 20
            color: Qt.rgba(0.08, 0.09, 0.13, 0.85)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.18)
            clip: true

            // Outer shadow / glow
            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: -1
                radius: 21
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Swallow clicks inside the card so backdrop doesn't dismiss accidentally
            MouseArea {
                anchors.fill: parent
            }

            // Keyboard navigation index
            property int currentWallIndex: 0

            readonly property string q: WallpaperManager.searchQuery.trim().toLowerCase()
            readonly property var filteredWallpapers: {
                const list = Wallpapers.list || [];
                if (!panelCard.q) return list;
                return list.filter(w => (w.name || "").toLowerCase().includes(panelCard.q));
            }

            onFilteredWallpapersChanged: {
                panelCard.currentWallIndex = 0;
            }

            function moveSelection(dx, dy) {
                const total = panelCard.filteredWallpapers.length;
                if (total === 0) return;
                const newIdx = panelCard.currentWallIndex + dx + (dy * 4);
                if (newIdx >= 0 && newIdx < total) {
                    panelCard.currentWallIndex = newIdx;
                } else if (newIdx < 0) {
                    panelCard.currentWallIndex = 0;
                } else if (newIdx >= total) {
                    panelCard.currentWallIndex = total - 1;
                }
                grid.positionViewAtIndex(panelCard.currentWallIndex, GridView.Contain);
            }

            function applyCurrent() {
                if (panelCard.filteredWallpapers.length > 0 && panelCard.currentWallIndex >= 0 && panelCard.currentWallIndex < panelCard.filteredWallpapers.length) {
                    const wall = panelCard.filteredWallpapers[panelCard.currentWallIndex];
                    Wallpapers.setWallpaper(wall.path);
                    WallpaperManager.closePicker();
                }
            }

            Connections {
                target: WallpaperManager
                function onOpenChanged() {
                    if (WallpaperManager.open) {
                        wallSearchInput.text = "";
                        panelCard.currentWallIndex = 0;
                        Qt.callLater(() => wallSearchInput.forceActiveFocus());
                    }
                }
            }

            // ---------- Top Header ----------
            Item {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 64

                // Left title & icon
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 12
                            color: Qt.rgba(244, 114, 182, 0.15)
                            border.width: 1
                            border.color: Qt.rgba(244, 114, 182, 0.3)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰸉"
                                font.family: Theme.iconFamily
                                renderType: Text.QtRendering
                                font.pixelSize: 20
                                color: "#F472B6"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "WALLPAPERS"
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                font.letterSpacing: 0.8
                            }

                            Text {
                                text: "Select a background for your displays"
                                color: Theme.fgDim
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Middle Search Box
                    Rectangle {
                        id: searchBox
                        anchors.centerIn: parent
                        width: 320
                        height: 36
                        radius: 18
                        color: Qt.rgba(255, 255, 255, 0.08)
                        border.width: 1
                        border.color: wallSearchInput.activeFocus ? Theme.accent : Qt.rgba(255, 255, 255, 0.15)

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                text: "󰍉"
                                font.family: Theme.iconFamily
                                font.pixelSize: 14
                                color: Theme.fgDim
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextInput {
                                id: wallSearchInput
                                width: parent.width - 45
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                selectionColor: Theme.accent
                                selectedTextColor: Theme.onAccent
                                clip: true

                                onTextChanged: {
                                    WallpaperManager.searchQuery = text;
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: wallSearchInput.text.length === 0
                                    text: "Filter wallpapers..."
                                    color: Theme.fgDim
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                }

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Escape) {
                                        WallpaperManager.closePicker();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Left) {
                                        panelCard.moveSelection(-1, 0);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Right) {
                                        panelCard.moveSelection(1, 0);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        panelCard.moveSelection(0, -1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        panelCard.moveSelection(0, 1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        panelCard.applyCurrent();
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                    }

                    // Right Actions: Random Wallpaper + Close Button
                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // Random Button
                        Rectangle {
                            height: 32
                            width: randomRow.implicitWidth + 18
                            radius: 16
                            color: randomMouse.containsMouse ? Qt.rgba(244, 114, 182, 0.25) : Qt.rgba(255, 255, 255, 0.08)
                            border.width: 1
                            border.color: randomMouse.containsMouse ? Qt.rgba(244, 114, 182, 0.45) : Qt.rgba(255, 255, 255, 0.12)

                            Row {
                                id: randomRow
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: "󰒝"
                                    font.family: Theme.iconFamily
                                    renderType: Text.QtRendering
                                    font.pixelSize: 13
                                    color: "#F472B6"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Random"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: Theme.fg
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: randomMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    WallpaperManager.setRandomWallpaper();
                                    WallpaperManager.closePicker();
                                }
                            }
                        }

                        // Close Button ("X")
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: closeMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.22) : Qt.rgba(255, 255, 255, 0.08)
                            border.width: 1
                            border.color: closeMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.45) : Qt.rgba(255, 255, 255, 0.12)

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: Theme.iconFamily
                                renderType: Text.QtRendering
                                font.pixelSize: 13
                                color: closeMouse.containsMouse ? "#EF4444" : Theme.fgDim
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperManager.closePicker()
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    id: topDivider
                    anchors.top: header.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // ---------- Grid View of Wallpapers ----------
                Item {
                    id: gridContainer
                    anchors.top: topDivider.bottom
                    anchors.bottom: bottomDivider.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    clip: true

                    GridView {
                        id: grid
                        anchors.fill: parent
                        anchors.margins: 12
                        clip: true
                        cellWidth: Math.floor(width / 4)
                        cellHeight: 126
                        model: panelCard.filteredWallpapers
                        currentIndex: panelCard.currentWallIndex
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Item {
                            id: cell
                            required property var modelData
                            required property int index
                            readonly property bool isSelected: index === panelCard.currentWallIndex
                            readonly property bool isCurrentDesktop: Wallpapers.currentWallpaperPath === modelData.path

                            width: grid.cellWidth
                            height: grid.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 10
                                color: cell.isSelected ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.05)
                                border.width: cell.isSelected ? 2 : (cell.isCurrentDesktop ? 1.5 : 0)
                                border.color: cell.isSelected ? "#F472B6" : "#34D399"
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: cell.isSelected ? 2 : 0
                                    source: cell.modelData.url
                                    sourceSize.width: 360
                                    sourceSize.height: 220
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                }

                                // Bottom Scrim with filename
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 28
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.88) }
                                    }

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 5
                                        text: cell.modelData.name
                                        color: "#FFFFFF"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        elide: Text.ElideMiddle
                                    }
                                }

                                // Active Desktop Badge
                                Rectangle {
                                    visible: cell.isCurrentDesktop
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                    anchors.right: parent.right
                                    anchors.rightMargin: 5
                                    height: 20
                                    width: activeBadgeRow.implicitWidth + 10
                                    radius: 10
                                    color: Qt.rgba(52, 211, 153, 0.90)

                                    Row {
                                        id: activeBadgeRow
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            text: "󰄬"
                                            font.family: Theme.iconFamily
                                            font.pixelSize: 10
                                            color: "#000000"
                                        }
                                        Text {
                                            text: "Active"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#000000"
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: {
                                        panelCard.currentWallIndex = cell.index;
                                    }
                                    onClicked: {
                                        panelCard.currentWallIndex = cell.index;
                                        Wallpapers.setWallpaper(cell.modelData.path);
                                        WallpaperManager.closePicker();
                                    }
                                }
                            }
                        }
                    }

                    // Empty State
                    Item {
                        anchors.centerIn: parent
                        visible: panelCard.filteredWallpapers.length === 0
                        width: parent.width
                        height: 80

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰅖"
                                font.family: Theme.iconFamily
                                font.pixelSize: 28
                                color: Qt.rgba(255, 255, 255, 0.25)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "No wallpapers found matching \"" + WallpaperManager.searchQuery + "\""
                                color: Theme.fgDim
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    id: bottomDivider
                    anchors.bottom: footer.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // ---------- Footer Key Hints ----------
                Item {
                    id: footer
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 38

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Row {
                            spacing: 5
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                width: 34; height: 18; radius: 4; color: Qt.rgba(255, 255, 255, 0.1)
                                Text { anchors.centerIn: parent; text: "←→↑↓"; font.pixelSize: 10; color: Theme.fgDim }
                            }
                            Text { text: "Navigate"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                        }

                        Row {
                            spacing: 5
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                width: 20; height: 18; radius: 4; color: Qt.rgba(255, 255, 255, 0.1)
                                Text { anchors.centerIn: parent; text: "↵"; font.pixelSize: 12; color: Theme.fgDim }
                            }
                            Text { text: "Apply Wallpaper"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                        }

                        Row {
                            spacing: 5
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                width: 28; height: 18; radius: 4; color: Qt.rgba(255, 255, 255, 0.1)
                                Text { anchors.centerIn: parent; text: "Esc"; font.pixelSize: 10; color: Theme.fgDim }
                            }
                            Text { text: "Dismiss"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        text: panelCard.filteredWallpapers.length + " wallpapers in ~/Pictures/wallpapers"
                        color: Theme.fgFaint
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
