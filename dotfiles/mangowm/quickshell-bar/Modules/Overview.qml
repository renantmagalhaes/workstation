pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../Config"

PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: OverviewManager.open

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-overview"
    WlrLayershell.keyboardFocus: (OverviewManager.open && (OverviewManager.focusedMonitor === monName)) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property bool open: OverviewManager.open
    readonly property var allClients: OverviewManager.allClients
    readonly property var allMonitors: OverviewManager.allMonitors
    readonly property int stamp: OverviewManager.stamp

    readonly property string monName: win.screen?.name ?? "DP-1"
    readonly property real monW: win.screen ? win.screen.width : 2560
    readonly property real monH: win.screen ? win.screen.height : 1440

    // Detect active tag for this monitor
    readonly property int activeTag: {
        const mon = allMonitors.find(m => m.name === monName);
        if (mon && Array.isArray(mon.active_tags) && mon.active_tags.length > 0 && mon.active_tags[0] > 0) {
            return mon.active_tags[0];
        }
        return 1;
    }

    // Windows belonging to this monitor (filtered by search or by active tag)
    readonly property var wins: {
        if (OverviewManager.isSearching) {
            const q = OverviewManager.searchQuery.trim().toLowerCase();
            return allClients.filter(c => {
                if (c.monitor !== monName || c.width <= 50 || c.height <= 50) return false;
                const title = (c.title ?? "").toLowerCase();
                const appid = (c.appid ?? "").toLowerCase();
                return title.includes(q) || appid.includes(q);
            });
        }
        return allClients.filter(c => {
            return c.monitor === monName && Array.isArray(c.tags) && c.tags.includes(activeTag) && !c.is_minimized && c.width > 50 && c.height > 50;
        });
    }

    // Layout metrics (Mission Control style)
    readonly property int stripTop: 24
    readonly property int cardCount: 5
    readonly property int cardGap: 16
    readonly property real cardH: Math.min(100, Math.floor(((width - 160 - (cardCount - 1) * cardGap) / cardCount) * monH / monW))
    readonly property real cardW: cardH * (monW / monH)
    readonly property int bandH: stripTop + cardH + 36

    readonly property int searchBarH: 44
    readonly property rect area: Qt.rect(
        80,
        bandH + searchBarH + 28,
        width - 160,
        height - bandH - searchBarH - 28 - 48
    )

    property int current: 0
    property bool keyboard: false
    property var dragged: null
    property point dragPos

    onOpenChanged: {
        if (open) {
            current = 0;
            keyboard = false;
            dragged = null;
            if (typeof searchInput !== "undefined" && searchInput) {
                searchInput.text = "";
            }
        }
    }

    // Optimal aspect-ratio grid layout algorithm from bezel-hyprland
    readonly property var layout: {
        const n = wins.length, W = area.width, H = area.height, gap = 24;
        if (!n) return [];
        const rs = wins.map(c => Qt.rect(c.x, c.y, c.width, c.height));
        let best = null;
        for (let r = 1; r <= n; r++) {
            const per = Math.ceil(n / r);
            const rows = [];
            for (let i = 0; i < n; i += per) {
                rows.push([...Array(Math.min(per, n - i)).keys()].map(k => i + k).sort((a, b) => rs[a].x - rs[b].x));
            }
            let h = (H - gap * (rows.length - 1)) / rows.length;
            for (const row of rows) {
                const aspect = row.reduce((s, i) => s + (rs[i].width / Math.max(1, rs[i].height)), 0);
                h = Math.min(h, (W - gap * (row.length - 1)) / aspect);
            }
            h = Math.min(h, Math.max(...rs.map(q => q.height)) * 0.85);
            if (!best || h > best.h) best = { h, rows };
        }
        const out = new Array(n);
        const totalH = best.rows.length * best.h + gap * (best.rows.length - 1);
        let y = area.y + (H - totalH) / 2;
        for (const row of best.rows) {
            const ws = row.map(i => best.h * (rs[i].width / Math.max(1, rs[i].height)));
            let x = area.x + (W - ws.reduce((s, w) => s + w, 0) - gap * (row.length - 1)) / 2;
            row.forEach((i, k) => {
                out[i] = Qt.rect(x, y, ws[k], best.h);
                x += ws[k] + gap;
            });
            y += best.h + gap;
        }
        return out;
    }

    function shotPath(cid) {
        return "file:///tmp/quickshell-overview/" + cid + ".ppm?" + stamp;
    }

    function appIcon(appId) {
        if (!appId) return "";
        const entry = DesktopEntries.heuristicLookup(appId);
        if (entry && entry.icon) {
            return Quickshell.iconPath(entry.icon, true);
        }
        return Quickshell.iconPath(appId, true);
    }

    function focusWindow(client) {
        OverviewManager.closeOverview();
        const targetTag = Array.isArray(client.tags) && client.tags.length > 0 ? client.tags[0] : 1;
        Quickshell.execDetached(["sh", "-c", `mmsg dispatch focusmon,${client.monitor}; mmsg dispatch view,${targetTag},1; mmsg dispatch focusid client,${client.id}`]);
    }

    function killWindow(client) {
        Quickshell.execDetached(["mmsg", "dispatch", "killclient", `client,${client.id}`]);
        OverviewManager.removeClient(client.id);
    }

    function moveWindow(client, tagId) {
        Quickshell.execDetached(["mmsg", "dispatch", `tag,${tagId},1`, `client,${client.id}`]);
        OverviewManager.updateClientTag(client.id, tagId);
    }

    function goWorkspace(wsId) {
        OverviewManager.closeOverview();
        Quickshell.execDetached(["sh", "-c", `mmsg dispatch focusmon,${monName}; mmsg dispatch view,${wsId},1`]);
    }

    function wsAt(p) {
        if (!p) return 0;
        for (let i = 0; i < cardsRepeater.count; i++) {
            const c = cardsRepeater.itemAt(i);
            if (!c) continue;
            const q = c.mapFromItem(null, p.x, p.y);
            if (q.x >= -16 && q.x <= c.width + 16 && q.y >= -30 && q.y <= c.height + 30) {
                return i + 1;
            }
        }
        return 0;
    }

    // ---------- Background Veil ----------
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.04, 0.05, 0.08, 0.82)
        opacity: win.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 220 } }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: OverviewManager.closeOverview()
        }
    }

    // ---------- Top Workspace Strip Band ----------
    Rectangle {
        width: parent.width
        height: win.bandH
        y: win.open ? 0 : -height
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        color: Qt.rgba(0.08, 0.09, 0.14, 0.88)
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        MouseArea {
            anchors.fill: parent
        }
    }

    Row {
        id: stripRow
        anchors.horizontalCenter: parent.horizontalCenter
        y: win.open ? win.stripTop : -win.cardH - 40
        spacing: win.cardGap
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        Repeater {
            id: cardsRepeater
            model: win.cardCount

            Item {
                id: wsCard
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: wsId === win.activeTag
                readonly property bool isDropTarget: win.dragged !== null && win.wsAt(win.dragPos) === wsId

                width: win.cardW
                height: win.cardH + 26
                z: isDropTarget ? 10 : 1

                Rectangle {
                    width: win.cardW
                    height: win.cardH
                    radius: 8
                    color: wsCard.isDropTarget ? Qt.rgba(0.12, 0.22, 0.35, 0.98) : wsCard.isActive ? Qt.rgba(0.12, 0.16, 0.24, 0.95) : Qt.rgba(0.06, 0.07, 0.10, 0.85)
                    border.width: wsCard.isDropTarget ? 3 : wsCard.isActive ? 2 : 1
                    border.color: wsCard.isDropTarget ? "#00E5FF" : wsCard.isActive ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.15)
                    clip: true
                    scale: wsCard.isDropTarget ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    // Miniature window blocks in this workspace
                    Repeater {
                        model: win.allClients.filter(c => c.monitor === win.monName && Array.isArray(c.tags) && c.tags.includes(wsCard.wsId) && c.width > 50)

                        Rectangle {
                            id: miniTile
                            required property var modelData
                            readonly property real scaleFactor: win.cardW / win.monW
                            readonly property real monOffX: win.screen ? win.screen.x : 0
                            readonly property real monOffY: win.screen ? win.screen.y : 0

                            x: Math.max(2, (modelData.x - monOffX) * scaleFactor)
                            y: Math.max(2, (modelData.y - monOffY) * scaleFactor)
                            width: Math.min(parent.width - 4, modelData.width * scaleFactor)
                            height: Math.min(parent.height - 4, modelData.height * scaleFactor)
                            radius: 3
                            color: Qt.rgba(0.18, 0.22, 0.32, 0.85)
                            border.color: Qt.rgba(1, 1, 1, 0.25)
                            border.width: 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: win.shotPath(miniTile.modelData.id)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                opacity: 0.85
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.goWorkspace(wsCard.wsId)
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "Workspace " + wsCard.wsId
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 12
                    font.bold: wsCard.isActive
                    color: wsCard.isActive ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.7)
                }
            }
        }
    }

    // ---------- Search Bar (Always Visible) ----------
    Rectangle {
        id: searchBar
        anchors.horizontalCenter: parent.horizontalCenter
        y: win.bandH + 12
        visible: win.open

        width: Math.min(480, parent.width - 160)
        height: 44
        radius: 22
        z: 50

        color: (searchInput.activeFocus || OverviewManager.isSearching)
            ? Qt.rgba(0.06, 0.08, 0.14, 0.96)
            : Qt.rgba(0.06, 0.08, 0.14, 0.75)
        border.width: (searchInput.activeFocus || OverviewManager.isSearching) ? 1.5 : 1
        border.color: (searchInput.activeFocus || OverviewManager.isSearching) ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.18)

        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 14
            spacing: 10

            Text {
                text: "🔍"
                font.pixelSize: 14
                color: (searchInput.activeFocus || OverviewManager.isSearching) ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.45)
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search open windows..."
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 14
                    color: Qt.rgba(1, 1, 1, 0.35)
                    visible: searchInput.text.length === 0
                }

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    selectionColor: "#00E5FF"
                    selectedTextColor: "#000000"
                    selectByMouse: true
                    clip: true

                    text: OverviewManager.searchQuery
                    onTextChanged: {
                        if (OverviewManager.searchQuery !== text) {
                            OverviewManager.searchQuery = text;
                            win.current = 0;
                            win.keyboard = true;
                        }
                    }

                    Keys.onPressed: event => {
                        const k = event.key;
                        const n = win.wins.length;

                        if (k === Qt.Key_Escape) {
                            if (text.length > 0) {
                                text = "";
                            } else {
                                OverviewManager.closeOverview();
                            }
                            event.accepted = true;
                        } else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && n > 0) {
                            win.focusWindow(win.wins[Math.min(win.current, n - 1)]);
                            event.accepted = true;
                        } else if (k === Qt.Key_Up) {
                            win.keyboard = true;
                            win.current = Math.max(0, win.current - 1);
                            event.accepted = true;
                        } else if (k === Qt.Key_Down || k === Qt.Key_Tab) {
                            win.keyboard = true;
                            win.current = n > 0 ? (win.current + 1) % n : 0;
                            event.accepted = true;
                        }
                    }
                }
            }

            // Results count badge (when searching)
            Rectangle {
                visible: OverviewManager.isSearching
                height: 22
                width: matchText.implicitWidth + 14
                radius: 11
                color: win.wins.length > 0 ? Qt.rgba(0, 0.9, 1, 0.15) : Qt.rgba(1, 0.4, 0.4, 0.18)
                border.width: 1
                border.color: win.wins.length > 0 ? Qt.rgba(0, 0.9, 1, 0.4) : Qt.rgba(1, 0.4, 0.4, 0.5)

                Text {
                    id: matchText
                    anchors.centerIn: parent
                    text: win.wins.length + (win.wins.length === 1 ? " match" : " matches")
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 11
                    font.bold: true
                    color: win.wins.length > 0 ? "#78FFB4" : "#FF7878"
                }
            }

            // Clear Button (✕)
            Rectangle {
                visible: OverviewManager.isSearching
                width: 22
                height: 22
                radius: 11
                color: clearMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 11
                    font.bold: true
                    color: clearMouse.containsMouse ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.6)
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchInput.text = "";
                        OverviewManager.searchQuery = "";
                        win.current = 0;
                    }
                }
            }
        }
    }


    // ---------- No Windows Message ----------
    Text {
        visible: win.wins.length === 0 && win.open
        anchors.centerIn: parent
        text: OverviewManager.isSearching
            ? `No windows matching "${OverviewManager.searchQuery}"`
            : "No active windows on this workspace"
        font.family: "Inter, sans-serif"
        font.pixelSize: 18
        color: Qt.rgba(1, 1, 1, 0.45)
    }

    // ---------- Center Windows Grid ----------
    Repeater {
        id: winRepeater
        model: win.wins

        Item {
            id: tile
            required property var modelData
            required property int index

            readonly property real monOffX: win.screen ? win.screen.x : 0
            readonly property real monOffY: win.screen ? win.screen.y : 0

            readonly property rect from: Qt.rect(
                modelData.x - monOffX,
                modelData.y - monOffY,
                modelData.width,
                modelData.height
            )
            readonly property rect to: win.layout[index] ?? from
            readonly property rect targetRect: win.open ? to : from

            readonly property bool isSelected: tileMouse.containsMouse || (win.keyboard && index === win.current)
            readonly property bool isDragged: win.dragged !== null && win.dragged.client.id === modelData.id

            x: targetRect.x
            y: targetRect.y
            width: targetRect.width
            height: targetRect.height

            visible: win.open
            opacity: isDragged ? 0.35 : 1.0

            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

            // Window thumbnail card
            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Qt.rgba(0.08, 0.10, 0.15, 0.92)
                border.width: tile.isSelected ? 2.5 : 1.5
                border.color: tile.isSelected ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.18)
                clip: true

                Behavior on border.color { ColorAnimation { duration: 150 } }

                Image {
                    id: tileShot
                    anchors.fill: parent
                    anchors.margins: 2
                    source: win.shotPath(tile.modelData.id)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            fallbackCol.visible = false;
                        }
                    }
                }

                // Workspace tag badge when searching
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8
                    height: 22
                    width: wsBadgeRow.implicitWidth + 14
                    radius: 11
                    color: Qt.rgba(0.06, 0.08, 0.12, 0.90)
                    border.color: "#00E5FF"
                    border.width: 1
                    visible: OverviewManager.isSearching
                    z: 5

                    RowLayout {
                        id: wsBadgeRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "WS " + (Array.isArray(tile.modelData.tags) && tile.modelData.tags.length > 0 ? tile.modelData.tags[0] : 1)
                            font.family: "Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#00E5FF"
                        }
                    }
                }

                // Fallback app icon if screenshot isn't available
                ColumnLayout {
                    id: fallbackCol
                    anchors.centerIn: parent
                    spacing: 8
                    visible: tileShot.status !== Image.Ready

                    IconImage {
                        Layout.alignment: Qt.AlignHCenter
                        implicitSize: 52
                        source: win.appIcon(tile.modelData.appid)
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: tile.modelData.appid ?? ""
                        font.family: "Inter, sans-serif"
                        font.pixelSize: 13
                        color: Qt.rgba(1, 1, 1, 0.7)
                    }
                }
            }

            // Window Title & App Pill below the card
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 8
                width: Math.min(titleRow.implicitWidth + 24, Math.max(parent.width, 180))
                height: 30
                radius: 15
                color: Qt.rgba(0.06, 0.08, 0.12, 0.90)
                border.width: 1
                border.color: tile.isSelected ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.18)

                RowLayout {
                    id: titleRow
                    anchors.centerIn: parent
                    spacing: 6

                    IconImage {
                        implicitSize: 18
                        source: win.appIcon(tile.modelData.appid)
                    }

                    Text {
                        Layout.maximumWidth: 260
                        text: tile.modelData.title ?? tile.modelData.appid
                        font.family: "Inter, sans-serif"
                        font.pixelSize: 12
                        font.bold: tile.isSelected
                        color: tile.isSelected ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.8)
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                id: tileMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                cursorShape: win.dragged ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                property point pressStart

                onEntered: win.current = tile.index
                onPressed: mouse => pressStart = Qt.point(mouse.x, mouse.y)

                onPositionChanged: mouse => {
                    if (!pressed || !(pressedButtons & Qt.LeftButton)) return;
                    if (!win.dragged && Math.hypot(mouse.x - pressStart.x, mouse.y - pressStart.y) > 8) {
                        win.dragged = {
                            client: tile.modelData,
                            icon: win.appIcon(tile.modelData.appid),
                            title: tile.modelData.title
                        };
                    }
                    if (win.dragged) {
                        win.dragPos = mapToItem(null, mouse.x, mouse.y);
                    }
                }

                onReleased: mouse => {
                    if (mouse.button === Qt.MiddleButton) {
                        win.killWindow(tile.modelData);
                        return;
                    }
                    if (win.dragged) {
                        const dropPoint = mapToItem(null, mouse.x, mouse.y);
                        const targetWs = win.wsAt(dropPoint) || win.wsAt(win.dragPos);
                        if (targetWs && targetWs !== win.activeTag) {
                            win.moveWindow(tile.modelData, targetWs);
                        }
                        win.dragged = null;
                    } else {
                        win.focusWindow(tile.modelData);
                    }
                }
            }
        }
    }

    // ---------- Dragged Window Follower ----------
    Rectangle {
        visible: win.dragged !== null
        x: win.dragPos.x - width / 2
        y: win.dragPos.y - height / 2
        width: dragLayout.implicitWidth + 24
        height: 38
        radius: 19
        color: Qt.rgba(0.08, 0.12, 0.18, 0.95)
        border.width: 1.5
        border.color: "#00E5FF"
        z: 100

        RowLayout {
            id: dragLayout
            anchors.centerIn: parent
            spacing: 8

            IconImage {
                implicitSize: 20
                source: win.dragged?.icon ?? ""
            }

            Text {
                text: win.dragged?.title ?? ""
                font.family: "Inter, sans-serif"
                font.pixelSize: 13
                color: "#FFFFFF"
                Layout.maximumWidth: 260
                elide: Text.ElideRight
            }
        }
    }

    // ---------- Keyboard Navigation Item ----------
    Item {
        anchors.fill: parent
        focus: win.open

        Keys.onPressed: event => {
            if (!win.open) return;
            const k = event.key;
            const n = win.wins.length;

            if (k === Qt.Key_Escape) {
                if (OverviewManager.isSearching) {
                    OverviewManager.searchQuery = "";
                    win.current = 0;
                } else {
                    OverviewManager.closeOverview();
                }
                event.accepted = true;
            } else if (k === Qt.Key_Backspace) {
                if (OverviewManager.searchQuery.length > 0) {
                    OverviewManager.searchQuery = OverviewManager.searchQuery.slice(0, -1);
                    win.current = 0;
                    win.keyboard = true;
                }
                event.accepted = true;
            } else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && n > 0) {
                win.focusWindow(win.wins[Math.min(win.current, n - 1)]);
                event.accepted = true;
            } else if (k === Qt.Key_Left || k === Qt.Key_Up) {
                win.keyboard = true;
                win.current = Math.max(0, win.current - 1);
                event.accepted = true;
            } else if (k === Qt.Key_Right || k === Qt.Key_Down || k === Qt.Key_Tab) {
                win.keyboard = true;
                win.current = n > 0 ? (win.current + 1) % n : 0;
                event.accepted = true;
            } else if (!OverviewManager.isSearching && k >= Qt.Key_1 && k <= Qt.Key_5) {
                win.goWorkspace(k - Qt.Key_0);
                event.accepted = true;
            } else if (event.text && event.text.length > 0 && event.text.charCodeAt(0) >= 32) {
                if (!(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                    searchInput.forceActiveFocus();
                    searchInput.text += event.text;
                    searchInput.cursorPosition = searchInput.text.length;
                    win.current = 0;
                    win.keyboard = true;
                    event.accepted = true;
                }
            }
        }
    }
}
