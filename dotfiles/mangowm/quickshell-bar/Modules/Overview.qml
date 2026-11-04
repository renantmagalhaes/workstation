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
            return c.monitor === monName && win.clientHasTag(c, activeTag) && !c.is_minimized && c.width > 50 && c.height > 50;
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

    readonly property real monX: win.screen ? win.screen.x : 0
    readonly property real monY: win.screen ? win.screen.y : 0

    readonly property real localCursorX: OverviewManager.dragGlobalX - monX
    readonly property real localCursorY: OverviewManager.dragGlobalY - monY
    readonly property bool isCursorOnThisScreen: OverviewManager.dragged !== null &&
        localCursorX >= 0 && localCursorX < width &&
        localCursorY >= 0 && localCursorY < height

    readonly property var dragged: OverviewManager.dragged
    readonly property point dragPos: Qt.point(localCursorX, localCursorY)

    readonly property int hoveredWs: {
        if (!win.isCursorOnThisScreen) return 0;
        return win.wsAt(Qt.point(win.localCursorX, win.localCursorY));
    }

    readonly property string hoveredOtherMon: {
        if (!win.isCursorOnThisScreen) return "";
        return win.otherMonAt(Qt.point(win.localCursorX, win.localCursorY));
    }

    readonly property bool isOverDesktop: win.isCursorOnThisScreen && hoveredWs === 0 && hoveredOtherMon === ""

    onHoveredWsChanged: {
        if (win.isCursorOnThisScreen && hoveredWs > 0) {
            OverviewManager.hoverMonitor = win.monName;
            OverviewManager.hoverWorkspace = hoveredWs;
        }
    }

    onHoveredOtherMonChanged: {
        if (win.isCursorOnThisScreen && hoveredOtherMon !== "") {
            OverviewManager.hoverMonitor = hoveredOtherMon;
            OverviewManager.hoverWorkspace = 0;
        }
    }

    onIsOverDesktopChanged: {
        if (win.isCursorOnThisScreen && isOverDesktop) {
            OverviewManager.hoverMonitor = win.monName;
            OverviewManager.hoverWorkspace = 0;
        }
    }

    onIsCursorOnThisScreenChanged: {
        if (win.isCursorOnThisScreen) {
            if (hoveredWs > 0) {
                OverviewManager.hoverMonitor = win.monName;
                OverviewManager.hoverWorkspace = hoveredWs;
            } else if (hoveredOtherMon !== "") {
                OverviewManager.hoverMonitor = hoveredOtherMon;
                OverviewManager.hoverWorkspace = 0;
            } else {
                OverviewManager.hoverMonitor = win.monName;
                OverviewManager.hoverWorkspace = 0;
            }
        }
    }

    onOpenChanged: {
        if (open) {
            current = 0;
            keyboard = false;
            OverviewManager.clearDrag();
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
        return "file:///tmp/quickshell-overview/" + cid + ".jpg?" + (stamp % 2);
    }

    function appIcon(appId) {
        if (!appId) return "";
        const entry = DesktopEntries.heuristicLookup(appId);
        if (entry && entry.icon) {
            return Quickshell.iconPath(entry.icon, true);
        }
        return Quickshell.iconPath(appId, true);
    }

    function clientTag(c) {
        if (!c) return "WS 1";
        const tags = c.tags;
        if (tags) {
            if (tags.length !== undefined && tags.length > 0) {
                const parts = [];
                for (let i = 0; i < tags.length; i++) {
                    parts.push(tags[i]);
                }
                return "WS " + parts.join(",");
            }
            if (typeof tags === "number") {
                return "WS " + tags;
            }
            if (tags[0] !== undefined) {
                return "WS " + tags[0];
            }
        }
        if (typeof c.tag === "number") {
            return "WS " + c.tag;
        }
        return "WS " + (win.activeTag || 1);
    }

    function clientHasTag(c, tagId) {
        if (!c || !c.tags) return false;
        const tags = c.tags;
        if (tags.length !== undefined) {
            for (let i = 0; i < tags.length; i++) {
                if (tags[i] === tagId) return true;
            }
            return false;
        }
        return tags === tagId;
    }

    function focusWindow(client) {
        OverviewManager.closeOverview();
        let targetTag = 1;
        if (client && client.tags) {
            if (client.tags.length !== undefined && client.tags.length > 0) {
                targetTag = client.tags[0];
            } else if (typeof client.tags === "number") {
                targetTag = client.tags;
            }
        } else if (client && typeof client.tag === "number") {
            targetTag = client.tag;
        }
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

    function moveWindowToMonitor(client, targetMon, tagId) {
        let cmd = `mmsg dispatch tagmon,${targetMon} client,${client.id}`;
        if (tagId && tagId > 0) {
            cmd += `; mmsg dispatch tag,${tagId},1 client,${client.id}`;
        }
        Quickshell.execDetached(["sh", "-c", cmd]);
        OverviewManager.updateClientMonitor(client.id, targetMon, tagId);
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
            if (q.x >= -12 && q.x <= c.width + 12 && q.y >= -20 && q.y <= c.height + 25) {
                return i + 1;
            }
        }
        return 0;
    }

    function otherMonAt(p) {
        // Disabled for now to preserve workspace strip symmetry
        return "";
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
                readonly property bool isDropTarget: OverviewManager.dragged !== null &&
                    OverviewManager.hoverMonitor === win.monName && OverviewManager.hoverWorkspace === wsId

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
                    scale: wsCard.isDropTarget ? 1.10 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.4
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    // Miniature window blocks in this workspace
                    Repeater {
                        model: win.allClients.filter(c => c.monitor === win.monName && win.clientHasTag(c, wsCard.wsId) && c.width > 50)

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
                                source: win.open ? win.shotPath(miniTile.modelData.id) : ""
                                sourceSize.width: 160
                                sourceSize.height: 100
                                cache: false
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

        /*
        // Divider before other monitor drop cards (commented out to preserve workspace symmetry)
        Rectangle {
            visible: OverviewManager.otherMonitorsFor(win.monName).length > 0
            width: 1
            height: win.cardH
            color: Qt.rgba(1, 1, 1, 0.15)
            anchors.verticalCenter: parent.verticalCenter
        }

        Repeater {
            id: otherMonRepeater
            model: OverviewManager.otherMonitorsFor(win.monName)

            Item {
                id: otherMonItem
                required property var modelData
                readonly property string targetMonName: modelData.name
                readonly property bool isDropTarget: OverviewManager.dragged !== null &&
                    OverviewManager.hoverMonitor === targetMonName && OverviewManager.hoverWorkspace === 0

                width: Math.max(120, win.cardW * 0.8)
                height: win.cardH + 26
                z: isDropTarget ? 10 : 1

                Rectangle {
                    width: parent.width
                    height: win.cardH
                    radius: 8
                    color: otherMonItem.isDropTarget ? Qt.rgba(0.12, 0.22, 0.35, 0.98) : Qt.rgba(0.06, 0.07, 0.10, 0.85)
                    border.width: otherMonItem.isDropTarget ? 3 : 1
                    border.color: otherMonItem.isDropTarget ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.15)
                    scale: otherMonItem.isDropTarget ? 1.08 : 1.0
                    clip: true

                    Behavior on scale { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰍹"
                            font.family: Theme.iconFamily
                            font.pixelSize: 22
                            color: otherMonItem.isDropTarget ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.7)
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: otherMonItem.targetMonName
                            font.family: "Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: otherMonItem.isDropTarget ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.8)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            OverviewManager.setActiveMonitor(otherMonItem.targetMonName);
                            Mango.dispatch(`focusmon,${otherMonItem.targetMonName}`);
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: otherMonItem.isDropTarget ? "Drop to Move" : "Send to Monitor"
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 11
                    color: otherMonItem.isDropTarget ? "#00E5FF" : Qt.rgba(1, 1, 1, 0.5)
                }
            }
        }
        */
    }

    // ---------- Cross-Monitor Drop Target Banner ----------
    Rectangle {
        id: crossMonDropZone
        visible: win.open && OverviewManager.dragged !== null &&
                 OverviewManager.dragged.sourceMonitor !== win.monName &&
                 win.isCursorOnThisScreen && win.hoveredWs === 0
        anchors.centerIn: parent
        width: Math.min(540, parent.width - 160)
        height: 110
        radius: 16
        color: Qt.rgba(0.04, 0.14, 0.20, 0.92)
        border.width: 2
        border.color: "#00E5FF"
        z: 45

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "󰍹 Move to " + win.monName
                font.family: Theme.iconFamily
                font.pixelSize: 20
                font.bold: true
                color: "#00E5FF"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Release to place on Workspace " + win.activeTag + " of this monitor"
                font.family: "Inter, sans-serif"
                font.pixelSize: 13
                color: "#FFFFFF"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Or drag up to a preview card above for a specific workspace"
                font.family: "Inter, sans-serif"
                font.pixelSize: 11
                color: Qt.rgba(1, 1, 1, 0.6)
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
                            if (OverviewManager.dragged !== null) {
                                OverviewManager.clearDrag();
                            } else if (text.length > 0) {
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
                            if (win.current > 0) {
                                win.current--;
                            } else {
                                OverviewManager.switchMonitor("left");
                            }
                            event.accepted = true;
                        } else if (k === Qt.Key_Down || k === Qt.Key_Tab) {
                            win.keyboard = true;
                            if (win.current < n - 1) {
                                win.current++;
                            } else {
                                OverviewManager.switchMonitor("right");
                            }
                            event.accepted = true;
                        } else if (k === Qt.Key_Right) {
                            if (searchInput.cursorPosition >= searchInput.text.length) {
                                win.keyboard = true;
                                if (win.current < n - 1) {
                                    win.current++;
                                } else {
                                    OverviewManager.switchMonitor("right");
                                }
                                event.accepted = true;
                            }
                        } else if (k === Qt.Key_Left) {
                            if (searchInput.cursorPosition <= 0) {
                                win.keyboard = true;
                                if (win.current > 0) {
                                    win.current--;
                                } else {
                                    OverviewManager.switchMonitor("left");
                                }
                                event.accepted = true;
                            }
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

            readonly property bool wasJustMovedHere: OverviewManager.lastMovedClient !== null &&
                OverviewManager.lastMovedClient.id === modelData.id &&
                OverviewManager.lastMovedClient.targetMonitor === win.monName

            readonly property rect from: {
                if (wasJustMovedHere) {
                    const moveInfo = OverviewManager.lastMovedClient;
                    const deltaX = moveInfo.sourceScreenX - moveInfo.targetScreenX;
                    const deltaY = moveInfo.sourceScreenY - moveInfo.targetScreenY;

                    let startX = 0;
                    if (deltaX > 0) {
                        startX = win.width + 120;
                    } else if (deltaX < 0) {
                        startX = -modelData.width - 120;
                    } else {
                        startX = (win.width - modelData.width) / 2;
                    }

                    let startY = 0;
                    if (deltaY > 0) {
                        startY = win.height + 120;
                    } else if (deltaY < 0) {
                        startY = -modelData.height - 120;
                    } else {
                        startY = (win.layout[index] ? win.layout[index].y : (win.height - modelData.height) / 2);
                    }

                    return Qt.rect(startX, startY, modelData.width, modelData.height);
                }

                return Qt.rect(
                    modelData.x - monOffX,
                    modelData.y - monOffY,
                    modelData.width,
                    modelData.height
                );
            }
            readonly property rect to: win.layout[index] ?? from
            readonly property rect targetRect: win.open ? to : from

            readonly property bool isSelected: tileMouse.containsMouse || (win.keyboard && (OverviewManager.activeMonitorName === win.monName) && index === win.current)
            readonly property bool isDragged: win.dragged !== null && win.dragged.client.id === modelData.id

            x: targetRect.x
            y: targetRect.y
            width: targetRect.width
            height: targetRect.height

            visible: win.open
            opacity: isDragged ? 0.35 : 1.0
            z: isSelected ? 25 : 1

            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

            Component.onCompleted: {
                if (tile.wasJustMovedHere) {
                    tile.x = tile.from.x;
                    tile.y = tile.from.y;
                    Qt.callLater(() => {
                        tile.x = Qt.binding(() => tile.targetRect.x);
                        tile.y = Qt.binding(() => tile.targetRect.y);
                    });
                }
            }

            // Ambient glow behind the lifted card
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                radius: 14
                color: "transparent"
                border.width: (tile.isSelected && !tile.isDragged) ? 3 : 0
                border.color: Qt.rgba(0.47, 1.0, 0.70, 0.35)
                opacity: (tile.isSelected && !tile.isDragged) ? 1 : 0
                scale: (tile.isSelected && !tile.isDragged) ? 1.03 : 1.0
                z: -1

                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
            }

            // Window thumbnail card with 3D tactile lift
            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Qt.rgba(0.08, 0.10, 0.15, 0.92)
                border.width: tile.isSelected ? 2.5 : 1.5
                border.color: tile.isSelected ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.18)
                clip: true
                scale: (tile.isSelected && !tile.isDragged) ? 1.03 : 1.0
                y: (tile.isSelected && !tile.isDragged) ? -4 : 0

                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

                Image {
                    id: tileShot
                    anchors.fill: parent
                    anchors.margins: 2
                    source: win.open ? win.shotPath(tile.modelData.id) : ""
                    sourceSize.width: 720
                    sourceSize.height: 405
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            fallbackCol.visible = false;
                        }
                    }
                }

                // Workspace tag badge (top-left)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 7
                    height: 22
                    width: wsBadgeRow.implicitWidth + 14
                    radius: 11
                    color: Qt.rgba(0.06, 0.08, 0.12, 0.90)
                    border.color: "#00E5FF"
                    border.width: 1
                    visible: true
                    z: 15

                    RowLayout {
                        id: wsBadgeRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: win.clientTag(tile.modelData)
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

                onEntered: {
                    OverviewManager.setActiveMonitor(win.monName);
                    win.current = tile.index;
                }
                onPressed: mouse => pressStart = Qt.point(mouse.x, mouse.y)

                onPositionChanged: mouse => {
                    if (!pressed || !(pressedButtons & Qt.LeftButton)) return;
                    if (!OverviewManager.dragged && Math.hypot(mouse.x - pressStart.x, mouse.y - pressStart.y) > 8) {
                        OverviewManager.startDrag(
                            tile.modelData,
                            win.appIcon(tile.modelData.appid),
                            tile.modelData.title,
                            win.monName,
                            win.clientTag(tile.modelData)
                        );
                    }
                    if (OverviewManager.dragged) {
                        const localPt = tile.mapToItem(null, mouse.x, mouse.y);
                        const gx = win.monX + localPt.x;
                        const gy = win.monY + localPt.y;
                        OverviewManager.updateDragPos(gx, gy);
                    }
                }

                onReleased: mouse => {
                    if (mouse.button === Qt.MiddleButton) {
                        win.killWindow(tile.modelData);
                        return;
                    }
                    if (OverviewManager.dragged) {
                        const client = OverviewManager.dragged.client;
                        const targetMon = OverviewManager.hoverMonitor || win.monName;
                        const targetWs = OverviewManager.hoverWorkspace;

                        if (targetMon !== client.monitor) {
                            win.moveWindowToMonitor(client, targetMon, targetWs);
                        } else if (targetWs && targetWs !== win.activeTag) {
                            win.moveWindow(client, targetWs);
                        }
                        OverviewManager.clearDrag();
                    } else {
                        win.focusWindow(tile.modelData);
                    }
                }
            }

            // Close window button (top-right) - Placed after tileMouse with z: 30 so it receives hover and clicks
            Rectangle {
                id: closeBtn
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 7
                width: 24
                height: 24
                radius: 12
                z: 30
                color: closeBtnMouse.containsMouse ? "#FF3B30" : Qt.rgba(0.08, 0.10, 0.16, 0.85)
                border.width: 1
                border.color: closeBtnMouse.containsMouse ? "#FF5F56" : Qt.rgba(1, 1, 1, 0.25)

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100 } }
                scale: closeBtnMouse.containsMouse ? 1.15 : 1.0

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: closeBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: mouse => mouse.accepted = true
                    onClicked: mouse => {
                        mouse.accepted = true;
                        win.killWindow(tile.modelData);
                    }
                }
            }
        }
    }

    // ---------- Dragged Window Preview Follower (GNOME / Windows style) ----------
    Item {
        id: dragFollower
        visible: win.isCursorOnThisScreen && OverviewManager.dragged !== null
        z: 150

        // Calculate aspect-ratio-scaled dimensions
        readonly property real rawAspect: {
            const cl = OverviewManager.dragged?.client;
            if (cl && cl.width > 0 && cl.height > 0) {
                return cl.width / cl.height;
            }
            return 16 / 9;
        }
        readonly property real clampedAspect: Math.max(0.7, Math.min(2.1, rawAspect))
        readonly property real cardW: 220
        readonly property real cardH: Math.round(cardW / clampedAspect)

        width: cardW
        height: cardH + 32

        x: win.localCursorX - cardW / 2
        y: win.localCursorY - cardH / 2

        // Check if cursor is over the workspace strip / cards at the top
        readonly property bool isOverWorkspace: win.isCursorOnThisScreen &&
            (win.hoveredWs > 0 || win.hoveredOtherMon !== "" || (win.localCursorY >= 0 && win.localCursorY <= win.bandH + 12))

        // Target scale: shrink down to 70% of the workspace box when over the top workspace overview, 100% otherwise
        readonly property real shrinkScale: (win.cardW * 0.70) / cardW
        readonly property real targetScale: isOverWorkspace ? shrinkScale : 1.0

        // Scale transform anchored exactly at the cursor point (cardW / 2, cardH / 2)
        transform: Scale {
            origin.x: dragFollower.cardW / 2
            origin.y: dragFollower.cardH / 2
            xScale: dragFollower.targetScale
            yScale: dragFollower.targetScale

            Behavior on xScale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.15
                }
            }
            Behavior on yScale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.15
                }
            }
        }

        // Soft drop shadow / elevation glow behind the preview card
        Rectangle {
            anchors.fill: previewCard
            anchors.margins: -4
            radius: previewCard.radius + 3
            color: Qt.rgba(0, 0, 0, 0.55)
            z: -1
        }

        // Window Thumbnail Card
        Rectangle {
            id: previewCard
            width: parent.width
            height: dragFollower.cardH
            radius: 10
            color: Qt.rgba(0.08, 0.10, 0.15, 0.95)
            border.width: 2
            border.color: (OverviewManager.dragged?.sourceMonitor !== win.monName) ? "#78FFB4" : "#00E5FF"
            clip: true

            // Live window snapshot
            Image {
                id: dragShot
                anchors.fill: parent
                anchors.margins: 2
                source: (win.open && OverviewManager.dragged?.client?.id) ? win.shotPath(OverviewManager.dragged.client.id) : ""
                sourceSize.width: 480
                sourceSize.height: 270
                cache: false
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true

                onStatusChanged: {
                    if (status === Image.Ready) {
                        dragFallbackCol.visible = false;
                    }
                }
            }

            // Fallback app icon if screenshot isn't ready
            ColumnLayout {
                id: dragFallbackCol
                anchors.centerIn: parent
                spacing: 6
                visible: dragShot.status !== Image.Ready

                IconImage {
                    Layout.alignment: Qt.AlignHCenter
                    implicitSize: 42
                    source: OverviewManager.dragged?.icon ?? ""
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: OverviewManager.dragged?.client?.appid ?? ""
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.7)
                }
            }

            // Top-left workspace badge (e.g. "WS 1")
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 6
                height: 20
                width: dragWsBadgeText.implicitWidth + 12
                radius: 10
                color: Qt.rgba(0.06, 0.08, 0.12, 0.90)
                border.color: "#00E5FF"
                border.width: 1
                visible: !!(OverviewManager.dragged?.tagText)

                Text {
                    id: dragWsBadgeText
                    anchors.centerIn: parent
                    text: OverviewManager.dragged?.tagText ?? ""
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 10
                    font.bold: true
                    color: "#00E5FF"
                }
            }

            // Top-right cross-monitor destination pill (when dragged across screens)
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 6
                height: 20
                width: toMonBadge.implicitWidth + 12
                radius: 10
                color: Qt.rgba(0.06, 0.12, 0.10, 0.92)
                border.color: "#78FFB4"
                border.width: 1
                visible: OverviewManager.dragged?.sourceMonitor !== win.monName

                RowLayout {
                    id: toMonBadge
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "➜"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#78FFB4"
                    }

                    Text {
                        text: win.monName
                        font.family: "Inter, sans-serif"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#78FFB4"
                    }
                }
            }
        }

        // Attached Title Pill below the preview card
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: previewCard.bottom
            anchors.topMargin: 6
            width: Math.min(parent.width + 20, Math.max(140, dragTitleRow.implicitWidth + 20))
            height: 26
            radius: 13
            color: Qt.rgba(0.06, 0.08, 0.12, 0.94)
            border.width: 1
            border.color: (OverviewManager.dragged?.sourceMonitor !== win.monName) ? "#78FFB4" : Qt.rgba(1, 1, 1, 0.25)
            opacity: dragFollower.isOverWorkspace ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 160 }
            }

            RowLayout {
                id: dragTitleRow
                anchors.centerIn: parent
                spacing: 6

                IconImage {
                    implicitSize: 14
                    source: OverviewManager.dragged?.icon ?? ""
                }

                Text {
                    Layout.maximumWidth: parent.parent.width - 32
                    text: OverviewManager.dragged?.title ?? (OverviewManager.dragged?.client?.appid ?? "")
                    font.family: "Inter, sans-serif"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#FFFFFF"
                    elide: Text.ElideRight
                }
            }
        }
    }

    // Monitor Focus Synchronization
    Connections {
        target: OverviewManager
        function onActiveMonitorNameChanged() {
            if (OverviewManager.activeMonitorName === win.monName) {
                if (win.wins.length > 0) {
                    if (win.current < 0 || win.current >= win.wins.length) {
                        win.current = 0;
                    }
                }
                win.keyboard = true;
                if (OverviewManager.isSearching && searchInput) {
                    searchInput.forceActiveFocus();
                    searchInput.cursorPosition = searchInput.text.length;
                } else if (keyHandler) {
                    keyHandler.forceActiveFocus();
                }
            }
        }
    }

    // ---------- Keyboard Navigation Item ----------
    Item {
        id: keyHandler
        anchors.fill: parent
        focus: win.open && OverviewManager.activeMonitorName === win.monName

        Keys.onPressed: event => {
            if (!win.open) return;
            const k = event.key;
            const n = win.wins.length;

            if (k === Qt.Key_Escape) {
                if (OverviewManager.dragged !== null) {
                    OverviewManager.clearDrag();
                } else if (OverviewManager.isSearching) {
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
                if (win.current > 0) {
                    win.current--;
                } else {
                    OverviewManager.switchMonitor("left");
                }
                event.accepted = true;
            } else if (k === Qt.Key_Right || k === Qt.Key_Down || k === Qt.Key_Tab) {
                win.keyboard = true;
                if (win.current < n - 1) {
                    win.current++;
                } else {
                    OverviewManager.switchMonitor("right");
                }
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

