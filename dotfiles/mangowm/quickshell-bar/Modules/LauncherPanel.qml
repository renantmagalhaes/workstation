pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Config"
import "../Services"

Item {
    id: root

    readonly property int maxVisibleHeight: 480
    readonly property int panelWidth: 700

    width: panelWidth
    implicitWidth: panelWidth
    implicitHeight: Math.min(col.implicitHeight, 620)
    height: implicitHeight

    // Active query and mode
    readonly property string q: LauncherManager.searchQuery.trim().toLowerCase()
    readonly property string mode: LauncherManager.mode
    readonly property string kind: LauncherManager.kind

    // Window scoring & filtering
    function scoreWindow(win, query) {
        if (!query) return 1;
        const title = (win.title || "").toLowerCase();
        const appid = (win.appid || "").toLowerCase();
        if (title === query) return 1000;
        if (title.startsWith(query)) return 500;
        if (appid.startsWith(query)) return 400;

        const words = title.split(/[\s\-_\/]+/);
        for (let i = 0; i < words.length; i++) {
            if (words[i].startsWith(query)) return 300;
        }

        if (title.includes(query)) return 200;
        if (appid.includes(query)) return 150;

        let qi = 0;
        for (let i = 0; i < title.length && qi < query.length; i++) {
            if (title[i] === query[qi]) qi++;
        }
        if (qi === query.length) return 30;

        return 0;
    }

    readonly property var filteredWindows: {
        const list = LauncherManager.allClients || [];
        if (!q) return list;
        return list.map(w => ({ w, score: scoreWindow(w, q) }))
                   .filter(x => x.score > 0)
                   .sort((a, b) => b.score - a.score)
                   .map(x => x.w);
    }

    // App scoring & filtering
    function scoreApp(app, query) {
        if (!query) return 1;
        const name = (app.name || "").toLowerCase();
        const generic = (app.genericName || "").toLowerCase();
        const comment = (app.comment || "").toLowerCase();
        const id = (app.id || "").toLowerCase();
        const keywords = (app.keywords || []).join(" ").toLowerCase();

        if (name === query) return 1000;
        if (name.startsWith(query)) return 500;
        if (id.startsWith(query)) return 400;

        const words = name.split(/[\s\-_\/]+/);
        for (let i = 0; i < words.length; i++) {
            if (words[i].startsWith(query)) return 300;
        }

        if (generic.startsWith(query)) return 250;
        if (name.includes(query)) return 200;
        if (generic.includes(query)) return 150;
        if (keywords.includes(query)) return 100;
        if (comment.includes(query)) return 80;
        if (id.includes(query)) return 50;

        let qi = 0;
        for (let i = 0; i < name.length && qi < query.length; i++) {
            if (name[i] === query[qi]) qi++;
        }
        if (qi === query.length) return 30;

        return 0;
    }

    readonly property var filteredApps: {
        const list = LauncherManager.allApps || [];
        if (!q) {
            return list.slice(0, 30);
        }
        return list.map(a => ({ a, score: scoreApp(a, q) }))
                   .filter(x => x.score > 0)
                   .sort((a, b) => b.score - a.score || a.a.name.localeCompare(b.a.name))
                   .slice(0, 35)
                   .map(x => x.a);
    }

    // Filtered Shortcuts
    readonly property var filteredShortcuts: {
        const list = LauncherManager.shortcuts || [];
        if (!q) return list;
        return list.filter(s =>
            (s.key || "").toLowerCase().includes(q) ||
            (s.title || "").toLowerCase().includes(q) ||
            (s.desc || "").toLowerCase().includes(q) ||
            (s.category || "").toLowerCase().includes(q)
        );
    }

    // Filtered System Power Actions
    readonly property var filteredSystemActions: {
        const list = LauncherManager.systemActions || [];
        if (!q) return [];
        const terms = ["wallpaper", "wall", "paper", "lock", "suspend", "sleep", "reboot", "restart", "power", "shutdown", "reload", "logout", "quit", "exit"];
        const matchesTerm = terms.some(t => t.includes(q) || q.includes(t));
        if (!matchesTerm) return [];
        return list.filter(s =>
            s.id.includes(q) ||
            s.title.toLowerCase().includes(q) ||
            s.subtitle.toLowerCase().includes(q)
        );
    }

    // Filtered Themes
    readonly property var filteredThemes: {
        const list = Palettes.list || [];
        if (!q) return [];
        const isThemeQuery = q.includes("theme") || q.includes("color") || q.includes("palette");
        return list.filter(t =>
            isThemeQuery ||
            t.id.toLowerCase().includes(q) ||
            t.name.toLowerCase().includes(q) ||
            (t.note || "").toLowerCase().includes(q)
        );
    }

    // Unified list of items for ListView
    readonly property var modelItems: {
        const out = [];

        // 1. Prefix: Command runner (">" or "$")
        if (kind === "cmd") {
            const cmd = LauncherManager.searchQuery.replace(/^[>$]\s*/, "");
            out.push({
                isHeader: false,
                kind: "cmd",
                data: { cmd: cmd }
            });
            return out;
        }

        // 2. Prefix: Web search ("?")
        if (kind === "web") {
            const query = LauncherManager.searchQuery.replace(/^\?\s*/, "");
            out.push({
                isHeader: false,
                kind: "web",
                data: { query: query }
            });
            return out;
        }

        // 3. Prefix: File search ("/")
        if (kind === "files") {
            const files = LauncherManager.filesResults || [];
            if (files.length > 0) {
                out.push({
                    isHeader: true,
                    kind: "header",
                    title: "FILES & DIRECTORIES",
                    count: files.length
                });
                for (let i = 0; i < files.length; i++) {
                    out.push({
                        isHeader: false,
                        kind: "file",
                        data: files[i]
                    });
                }
            } else {
                out.push({
                    isHeader: false,
                    kind: "file_hint",
                    data: { query: LauncherManager.searchQuery.slice(1) }
                });
            }
            return out;
        }

        // 4. Calculator
        if (LauncherManager.calcResult) {
            out.push({
                isHeader: false,
                kind: "calc",
                data: LauncherManager.calcResult
            });
        }

        // 5. System Actions (in "all" mode when matching)
        if (mode === "all" && filteredSystemActions.length > 0) {
            out.push({
                isHeader: true,
                kind: "header",
                title: "SYSTEM ACTIONS",
                count: filteredSystemActions.length
            });
            for (let i = 0; i < filteredSystemActions.length; i++) {
                out.push({
                    isHeader: false,
                    kind: "system",
                    data: filteredSystemActions[i]
                });
            }
        }

        // 6. Themes (in "all" mode when matching)
        if (mode === "all" && filteredThemes.length > 0) {
            out.push({
                isHeader: true,
                kind: "header",
                title: "COLOR THEMES",
                count: filteredThemes.length
            });
            for (let i = 0; i < filteredThemes.length; i++) {
                out.push({
                    isHeader: false,
                    kind: "theme",
                    data: filteredThemes[i]
                });
            }
        }

        // 7. Open Windows
        if ((mode === "all" || mode === "windows") && filteredWindows.length > 0) {
            out.push({
                isHeader: true,
                kind: "header",
                title: "OPEN WINDOWS",
                count: filteredWindows.length
            });
            for (let i = 0; i < filteredWindows.length; i++) {
                out.push({
                    isHeader: false,
                    kind: "window",
                    data: filteredWindows[i]
                });
            }
        }

        // 8. Applications
        if ((mode === "all" || mode === "apps") && filteredApps.length > 0) {
            out.push({
                isHeader: true,
                kind: "header",
                title: "APPLICATIONS",
                count: filteredApps.length
            });
            for (let i = 0; i < filteredApps.length; i++) {
                out.push({
                    isHeader: false,
                    kind: "app",
                    data: filteredApps[i]
                });
            }
        }

        // 9. Shortcuts
        if (mode === "shortcuts") {
            if (filteredShortcuts.length > 0) {
                out.push({
                    isHeader: true,
                    kind: "header",
                    title: "MANGO WM SHORTCUTS",
                    count: filteredShortcuts.length
                });
                for (let i = 0; i < filteredShortcuts.length; i++) {
                    out.push({
                        isHeader: false,
                        kind: "shortcut",
                        data: filteredShortcuts[i]
                    });
                }
            }
        }

        return out;
    }

    // Selectable indices in modelItems
    readonly property var selectableIndices: {
        const indices = [];
        for (let i = 0; i < modelItems.length; i++) {
            if (!modelItems[i].isHeader) {
                indices.push(i);
            }
        }
        return indices;
    }

    property int currentSelectable: 0

    onModelItemsChanged: {
        currentSelectable = 0;
    }

    function moveSelection(delta) {
        const total = selectableIndices.length;
        if (total === 0) return;
        currentSelectable = (currentSelectable + delta + total) % total;
        ensureVisible();
    }

    function ensureVisible() {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        listView.positionViewAtIndex(targetModelIndex, ListView.Contain);
    }

    function activateCurrent(shift) {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        const item = modelItems[targetModelIndex];
        if (!item || item.isHeader) return;

        if (item.kind === "calc") {
            LauncherManager.copyCalc(item.data.raw ?? item.data.result);
        } else if (item.kind === "window") {
            if (shift) {
                LauncherManager.launchWindowApp(item.data);
            } else {
                LauncherManager.focusWindow(item.data);
            }
        } else if (item.kind === "app") {
            LauncherManager.launchApp(item.data);
        } else if (item.kind === "cmd") {
            LauncherManager.executeCommand(item.data.cmd, shift);
        } else if (item.kind === "web") {
            LauncherManager.searchWeb(item.data.query);
        } else if (item.kind === "file") {
            LauncherManager.openFile(item.data.path, shift);
        } else if (item.kind === "system") {
            LauncherManager.executeSystemAction(item.data);
        } else if (item.kind === "theme") {
            Settings.theme = item.data.id;
            LauncherManager.closeLauncher();
        }
    }

    function killCurrent() {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        const item = modelItems[targetModelIndex];
        if (!item) return;

        if (item.kind === "window") {
            LauncherManager.killWindow(item.data);
        }
    }

    Connections {
        target: LauncherManager
        function onOpenChanged() {
            if (LauncherManager.open) {
                input.text = "";
                currentSelectable = 0;
                Qt.callLater(() => input.forceActiveFocus());
            }
        }
    }

    // Card background with rounded corners and translucent dark glass
    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(0.08, 0.09, 0.13, 0.75)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.18)

        // Outer glow/shadow
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -1
            radius: 19
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
        }
    }

    Column {
        id: col
        width: parent.width

        // ---------- Top Search Row ----------
        Item {
            id: searchRow
            width: parent.width
            height: 58

            // Prompt Icon
            Text {
                id: promptIcon
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.iconFamily
                renderType: Text.QtRendering
                font.pixelSize: 20
                color: {
                    if (root.kind === "calc") return "#00E5FF";
                    if (root.kind === "cmd") return "#34D399";
                    if (root.kind === "files") return "#FBBF24";
                    if (root.kind === "web") return "#60A5FA";
                    if (root.mode === "shortcuts") return "#FBBF24";
                    if (root.mode === "windows") return "#A78BFA";
                    return Theme.accent;
                }
                text: {
                    if (root.kind === "calc") return "󰃬";
                    if (root.kind === "cmd") return "󰞌";
                    if (root.kind === "files") return "󰉋";
                    if (root.kind === "web") return "󰍉";
                    if (root.mode === "shortcuts") return "󰌌";
                    if (root.mode === "windows") return "󱂬";
                    return "󰍉";
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            // Right Controls Container: Clear Button + Mode Tabs + Close Launcher Button
            Row {
                id: rightControls
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                z: 10

                // Clear input button
                Rectangle {
                    id: clearBtn
                    width: 24
                    height: 24
                    radius: 12
                    visible: input.text.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: clearMouse.containsMouse ? Theme.hover : Qt.rgba(255, 255, 255, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: clearMouse.containsMouse ? Theme.fg : Theme.fgDim
                        font.family: Theme.iconFamily
                        renderType: Text.QtRendering
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            input.text = "";
                            input.forceActiveFocus();
                        }
                    }
                }

                // Mode Pills / Tabs
                Row {
                    id: modeTabs
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: LauncherManager.availableModes

                        Rectangle {
                            id: tabItem
                            required property var modelData
                            readonly property bool isActive: root.mode === modelData.id
                            height: 28
                            width: tabRow.implicitWidth + 14
                            radius: 14
                            color: isActive ? Qt.rgba(255, 255, 255, 0.14) : (tabMouse.containsMouse ? Theme.hover : "transparent")
                            border.width: 1
                            border.color: isActive ? Qt.rgba(255, 255, 255, 0.22) : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 140 }
                            }

                            Row {
                                id: tabRow
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: tabItem.modelData.icon
                                    color: {
                                        if (!tabItem.isActive) return Theme.fgDim;
                                        if (tabItem.modelData.id === "windows") return "#A78BFA";
                                        if (tabItem.modelData.id === "shortcuts") return "#FBBF24";
                                        return Theme.accent;
                                    }
                                    font.family: Theme.iconFamily
                                    renderType: Text.QtRendering
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: {
                                        if (tabItem.isActive) {
                                            if (tabItem.modelData.id === "windows") {
                                                return "Windows (" + root.filteredWindows.length + ")";
                                            }
                                            return tabItem.modelData.label;
                                        }
                                        // Compact labels for inactive tabs
                                        if (tabItem.modelData.id === "all") return "All";
                                        if (tabItem.modelData.id === "windows") return "Win";
                                        if (tabItem.modelData.id === "apps") return "Apps";
                                        if (tabItem.modelData.id === "shortcuts") return "Keys";
                                        return tabItem.modelData.label;
                                    }
                                    color: tabItem.isActive ? Theme.fg : Theme.fgDim
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: tabItem.isActive ? Font.Bold : Font.Normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: tabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    LauncherManager.setMode(tabItem.modelData.id);
                                    input.forceActiveFocus();
                                }
                            }
                        }
                    }
                }

                // Close Launcher Window Button ("X")
                Rectangle {
                    id: closeLauncherBtn
                    width: 28
                    height: 28
                    radius: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: closeLauncherMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.22) : Qt.rgba(255, 255, 255, 0.08)
                    border.width: 1
                    border.color: closeLauncherMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.45) : Qt.rgba(255, 255, 255, 0.12)

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Theme.iconFamily
                        renderType: Text.QtRendering
                        font.pixelSize: 13
                        color: closeLauncherMouse.containsMouse ? "#EF4444" : Theme.fgDim
                    }

                    MouseArea {
                        id: closeLauncherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            LauncherManager.closeLauncher();
                        }
                    }
                }
            }

            // Text Input
            TextInput {
                id: input
                anchors.left: promptIcon.right
                anchors.leftMargin: 14
                anchors.right: rightControls.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 17
                font.weight: Font.Medium
                selectionColor: Theme.accent
                selectedTextColor: Theme.onAccent
                clip: true
                focus: LauncherManager.open

                onTextChanged: {
                    LauncherManager.searchQuery = text;
                }

                // Placeholder
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    elide: Text.ElideRight
                    visible: input.text.length === 0
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    text: {
                        if (root.kind === "cmd") return "Type shell command to execute...";
                        if (root.kind === "files") return "Search files and folders in home...";
                        if (root.kind === "web") return "Search web on DuckDuckGo...";
                        if (root.mode === "shortcuts") return "Search MangoWM shortcuts...";
                        if (root.mode === "windows") return "Search open windows...";
                        if (root.mode === "apps") return "Search applications...";
                        return "Search apps, open windows, =calc, >cmd, /files, ?web...";
                    }
                }

                Keys.onPressed: event => {
                    const shift = event.modifiers & Qt.ShiftModifier;
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    const alt = event.modifiers & Qt.AltModifier;

                    if (event.key === Qt.Key_Escape) {
                        LauncherManager.closeLauncher();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)) {
                        root.moveSelection(1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)) {
                        root.moveSelection(-1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageDown) {
                        root.moveSelection(5);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageUp) {
                        root.moveSelection(-5);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        LauncherManager.cycleMode(true);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Backtab) {
                        LauncherManager.cycleMode(false);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.activateCurrent(shift || alt || ctrl);
                        event.accepted = true;
                    } else if (shift && event.key === Qt.Key_Delete) {
                        root.killCurrent();
                        event.accepted = true;
                    }
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        // ---------- Results Area (ListView) ----------
        Item {
            id: listWrapper
            width: parent.width
            height: root.modelItems.length === 0 ? 120 : Math.min(listView.contentHeight, root.maxVisibleHeight)
            clip: true

            Behavior on height {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }

            ListView {
                id: listView
                anchors.fill: parent
                model: root.modelItems
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                topMargin: 6
                bottomMargin: 6

                delegate: Item {
                    id: delegateRoot
                    required property var modelData
                    required property int index

                    readonly property bool isHeader: modelData.isHeader
                    readonly property bool isSelected: {
                        if (isHeader) return false;
                        const curIdx = root.selectableIndices[root.currentSelectable];
                        return index === curIdx;
                    }

                    width: listView.width
                    height: {
                        if (isHeader) return 32;
                        if (modelData.kind === "calc") return 64;
                        if (modelData.kind === "cmd" || modelData.kind === "web") return 58;
                        return 54;
                    }

                    // Section Header
                    Loader {
                        active: delegateRoot.isHeader
                        anchors.fill: parent
                        sourceComponent: Item {
                            anchors.fill: parent
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8

                                Text {
                                    text: delegateRoot.modelData.title
                                    color: {
                                        if (delegateRoot.modelData.title.indexOf("WINDOWS") !== -1) return "#A78BFA";
                                        if (delegateRoot.modelData.title.indexOf("SYSTEM") !== -1) return "#EF4444";
                                        if (delegateRoot.modelData.title.indexOf("SHORTCUTS") !== -1) return "#FBBF24";
                                        return Theme.accent;
                                    }
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    height: 16
                                    width: countText.implicitWidth + 10
                                    radius: 8
                                    color: Qt.rgba(255, 255, 255, 0.08)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: countText
                                        anchors.centerIn: parent
                                        text: String(delegateRoot.modelData.count)
                                        color: Theme.fgDim
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }

                    // Selectable Item Row Background
                    Loader {
                        active: !delegateRoot.isHeader
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        sourceComponent: Rectangle {
                            id: rowBg
                            anchors.fill: parent
                            radius: 12
                            color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.12) : (rowMouse.containsMouse ? Theme.hover : "transparent")
                            border.width: delegateRoot.isSelected ? 1 : 0
                            border.color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.25) : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                enabled: delegateRoot.modelData.kind !== "window"
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const selIdx = root.selectableIndices.indexOf(delegateRoot.index);
                                    if (selIdx !== -1) {
                                        root.currentSelectable = selIdx;
                                    }
                                    root.activateCurrent(false);
                                }
                            }

                            // 1. CALC ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "calc"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 10
                                        color: Qt.rgba(0, 229, 255, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(0, 229, 255, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰃬"
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 20
                                            color: "#00E5FF"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: "= " + delegateRoot.modelData.data.result
                                            color: "#00E5FF"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 18
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: delegateRoot.modelData.data.expression
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: copyLabel.implicitWidth + 14
                                        radius: 6
                                        color: Qt.rgba(0, 229, 255, 0.2)
                                        Text {
                                            id: copyLabel
                                            anchors.centerIn: parent
                                            text: "↵ Enter to Copy"
                                            color: "#00E5FF"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            // 2. WINDOW ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "window"
                                anchors.fill: parent
                                z: 2
                                sourceComponent: Item {
                                    anchors.fill: parent

                                    Row {
                                        id: winActions
                                        anchors.right: parent.right
                                        anchors.rightMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6
                                        z: 10

                                        Rectangle {
                                            height: 24
                                            width: tagLabel.implicitWidth + 12
                                            radius: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: Qt.rgba(167, 139, 250, 0.15)
                                            border.width: 1
                                            border.color: Qt.rgba(167, 139, 250, 0.3)

                                            Text {
                                                id: tagLabel
                                                anchors.centerIn: parent
                                                text: "Tag " + (delegateRoot.modelData.data.tags?.[0] ?? 1)
                                                color: "#C4B5FD"
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                        }

                                        Rectangle {
                                            height: 26
                                            width: focusLabel.implicitWidth + 14
                                            radius: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: switchMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.25) : (delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.08))

                                            Text {
                                                id: focusLabel
                                                anchors.centerIn: parent
                                                text: delegateRoot.isSelected ? "↵ Switch" : "Switch"
                                                color: delegateRoot.isSelected ? Theme.fg : Theme.fgDim
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                font.bold: delegateRoot.isSelected
                                            }

                                            MouseArea {
                                                id: switchMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: (mouse) => {
                                                    mouse.accepted = true;
                                                    LauncherManager.focusWindow(delegateRoot.modelData.data);
                                                }
                                            }
                                        }

                                        Rectangle {
                                            height: 26
                                            width: newAppLabel.implicitWidth + 14
                                            radius: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: newAppMouse.containsMouse ? Qt.rgba(0, 229, 255, 0.25) : (delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.12) : "transparent")
                                            border.width: 1
                                            border.color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.2) : "transparent"

                                            Text {
                                                id: newAppLabel
                                                anchors.centerIn: parent
                                                text: "⇧+↵ New"
                                                color: delegateRoot.isSelected ? "#00E5FF" : Theme.fgDim
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                font.bold: delegateRoot.isSelected
                                            }

                                            MouseArea {
                                                id: newAppMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: (mouse) => {
                                                    mouse.accepted = true;
                                                    LauncherManager.launchWindowApp(delegateRoot.modelData.data);
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: closeWinBtn
                                            height: 26
                                            width: 28
                                            radius: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: closeWinMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.35) : Qt.rgba(255, 255, 255, 0.08)
                                            border.width: 1
                                            border.color: closeWinMouse.containsMouse ? Qt.rgba(239, 68, 68, 0.7) : Qt.rgba(255, 255, 255, 0.12)

                                            Behavior on color {
                                                ColorAnimation { duration: 100 }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "󰅖"
                                                font.family: Theme.iconFamily
                                                renderType: Text.QtRendering
                                                font.pixelSize: 13
                                                color: closeWinMouse.containsMouse ? "#EF4444" : Theme.fgDim
                                            }

                                            MouseArea {
                                                id: closeWinMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: (mouse) => {
                                                    mouse.accepted = true;
                                                    LauncherManager.killWindow(delegateRoot.modelData.data);
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: rowClickArea
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.right: winActions.left
                                        anchors.rightMargin: 8
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const selIdx = root.selectableIndices.indexOf(delegateRoot.index);
                                            if (selIdx !== -1) {
                                                root.currentSelectable = selIdx;
                                            }
                                            root.activateCurrent(false);
                                        }

                                        Item {
                                            id: winIconContainer
                                            width: 34
                                            height: 34
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter

                                            Image {
                                                id: winIconImg
                                                anchors.fill: parent
                                                source: LauncherManager.getWindowIcon(delegateRoot.modelData.data)
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                                visible: status === Image.Ready
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: !winIconImg.visible
                                                text: "󱂬"
                                                font.family: Theme.iconFamily
                                                renderType: Text.QtRendering
                                                font.pixelSize: 20
                                                color: "#A78BFA"
                                            }
                                        }

                                        Column {
                                            anchors.left: winIconContainer.right
                                            anchors.leftMargin: 12
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            Text {
                                                width: parent.width
                                                text: delegateRoot.modelData.data.title || "Window"
                                                color: delegateRoot.isSelected ? Theme.fg : Qt.rgba(1, 1, 1, 0.9)
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                width: parent.width
                                                text: (delegateRoot.modelData.data.appid || "app") + " • " + (delegateRoot.modelData.data.monitor || "")
                                                color: Theme.fgDim
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }

                            // 3. APP ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "app"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Item {
                                        Layout.preferredWidth: 34
                                        Layout.preferredHeight: 34

                                        Image {
                                            id: appIconImg
                                            anchors.fill: parent
                                            source: Quickshell.iconPath(delegateRoot.modelData.data.icon, true)
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            visible: status === Image.Ready
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !appIconImg.visible
                                            text: "󰀻"
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 20
                                            color: Theme.accent
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: delegateRoot.modelData.data.name || ""
                                            color: delegateRoot.isSelected ? Theme.fg : Qt.rgba(1, 1, 1, 0.9)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: delegateRoot.modelData.data.genericName || delegateRoot.modelData.data.comment || "Application"
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        visible: delegateRoot.modelData.data.runInTerminal === true
                                        Layout.preferredHeight: 20
                                        Layout.preferredWidth: termLabel.implicitWidth + 10
                                        radius: 5
                                        color: Qt.rgba(255, 255, 255, 0.08)

                                        Text {
                                            id: termLabel
                                            anchors.centerIn: parent
                                            text: "Terminal"
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: launchLabel.implicitWidth + 14
                                        radius: 6
                                        color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.06)

                                        Text {
                                            id: launchLabel
                                            anchors.centerIn: parent
                                            text: delegateRoot.isSelected ? "↵ Launch" : "Launch"
                                            color: delegateRoot.isSelected ? Theme.fg : Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: delegateRoot.isSelected
                                        }
                                    }
                                }
                            }

                            // 4. COMMAND ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "cmd"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 8
                                        color: Qt.rgba(52, 211, 153, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(52, 211, 153, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰞌"
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 18
                                            color: "#34D399"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.cmd ? "$ " + delegateRoot.modelData.data.cmd : "Type command to run..."
                                            color: "#34D399"
                                            font.family: "monospace"
                                            font.pixelSize: 15
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: "↵ Enter to run detached  •  ⇧+↵ in Kitty terminal"
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // 5. WEB SEARCH ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "web"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 8
                                        color: Qt.rgba(96, 165, 250, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(96, 165, 250, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰍉"
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 18
                                            color: "#60A5FA"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.query ? "Search web for \"" + delegateRoot.modelData.data.query + "\"" : "Search the web..."
                                            color: "#60A5FA"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: "Open with DuckDuckGo in default browser"
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // 6. FILE ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "file"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 34
                                        Layout.preferredHeight: 34
                                        radius: 8
                                        color: Qt.rgba(251, 191, 36, 0.12)

                                        Text {
                                            anchors.centerIn: parent
                                            text: delegateRoot.modelData.data.isDir ? "󰉋" : "󰈙"
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 18
                                            color: "#FBBF24"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.name
                                            color: delegateRoot.isSelected ? Theme.fg : Qt.rgba(1, 1, 1, 0.9)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: delegateRoot.modelData.data.parent
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        text: delegateRoot.isSelected ? "↵ Open" : ""
                                        color: Theme.fgDim
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            // 7. SHORTCUT ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "shortcut"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredHeight: 28
                                        Layout.preferredWidth: keyBadgeText.implicitWidth + 16
                                        radius: 6
                                        color: Qt.rgba(251, 191, 36, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(251, 191, 36, 0.3)

                                        Text {
                                            id: keyBadgeText
                                            anchors.centerIn: parent
                                            text: delegateRoot.modelData.data.key
                                            font.family: "monospace"
                                            font.bold: true
                                            font.pixelSize: 11
                                            color: "#FBBF24"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.title
                                            color: delegateRoot.isSelected ? Theme.fg : Qt.rgba(1, 1, 1, 0.9)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: delegateRoot.modelData.data.desc
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredHeight: 20
                                        Layout.preferredWidth: catText.implicitWidth + 10
                                        radius: 5
                                        color: Qt.rgba(255, 255, 255, 0.08)
                                        Text {
                                            id: catText
                                            anchors.centerIn: parent
                                            text: delegateRoot.modelData.data.category
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            // 8. SYSTEM ACTION ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "system"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 10
                                        color: Qt.rgba(239, 68, 68, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(239, 68, 68, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: delegateRoot.modelData.data.icon
                                            font.family: Theme.iconFamily
                                            renderType: Text.QtRendering
                                            font.pixelSize: 18
                                            color: delegateRoot.modelData.data.color || "#EF4444"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.title
                                            color: delegateRoot.modelData.data.color || Theme.fg
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: delegateRoot.modelData.data.subtitle
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: sysRunLabel.implicitWidth + 14
                                        radius: 6
                                        color: Qt.rgba(255, 255, 255, 0.1)
                                        Text {
                                            id: sysRunLabel
                                            anchors.centerIn: parent
                                            text: "↵ Execute"
                                            color: Theme.fg
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            // 9. THEME SWITCHER ITEM
                            Loader {
                                active: delegateRoot.modelData.kind === "theme"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    // Palette Color Swatches Preview
                                    Row {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 20
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: -6

                                        Rectangle {
                                            width: 18; height: 18; radius: 9
                                            color: delegateRoot.modelData.data.bg
                                            border.width: 1; border.color: "#FFFFFF"
                                        }
                                        Rectangle {
                                            width: 18; height: 18; radius: 9
                                            color: delegateRoot.modelData.data.accent
                                            border.width: 1; border.color: "#FFFFFF"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: delegateRoot.modelData.data.name
                                            color: Theme.fg
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: delegateRoot.modelData.data.note || "Color Theme"
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        visible: Settings.theme === delegateRoot.modelData.data.id
                                        Layout.preferredHeight: 22
                                        Layout.preferredWidth: activeThemeLabel.implicitWidth + 12
                                        radius: 6
                                        color: Qt.rgba(52, 211, 153, 0.2)
                                        Text {
                                            id: activeThemeLabel
                                            anchors.centerIn: parent
                                            text: "Active"
                                            color: "#34D399"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Empty State
            Item {
                anchors.centerIn: parent
                visible: root.modelItems.length === 0
                width: parent.width
                height: 80

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰅖"
                        font.family: Theme.iconFamily
                        renderType: Text.QtRendering
                        font.pixelSize: 26
                        color: Qt.rgba(255, 255, 255, 0.25)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (root.mode === "shortcuts") return "No matching shortcuts found";
                            if (root.mode === "windows") return "No open windows matching query";
                            return "No results found for \"" + LauncherManager.searchQuery + "\"";
                        }
                        color: Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                }
            }
        }

        // Divider above footer
        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        // ---------- Bottom Key Hint Bar ----------
        Item {
            id: footer
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "↑↓"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "Navigate"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "↵"; font.pixelSize: 11; color: Theme.fgDim }
                    }
                    Text {
                        text: "Open / Focus"
                        color: Theme.fgDim
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    visible: root.mode === "windows" || root.mode === "all" || root.kind === "cmd"
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 36; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "⇧+↵"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text {
                        text: root.kind === "cmd" ? "Terminal" : "New App"
                        color: Theme.fgDim
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 26; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "Tab"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "Mode"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    visible: root.mode === "windows"
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 44; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "⇧+Del"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text {
                        text: "Close Window"
                        color: Theme.fgDim
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 24; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "Esc"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "Dismiss"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // Right side mode badge
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (root.mode === "shortcuts") return root.filteredShortcuts.length + " shortcuts";
                    if (root.mode === "windows") return root.filteredWindows.length + " windows";
                    return "Spotlight Launcher";
                }
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }
    }
}
