pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Config"

Item {
    id: root

    readonly property int maxVisibleHeight: 480
    readonly property int panelWidth: 680

    width: panelWidth
    implicitHeight: Math.min(col.implicitHeight, 620)

    // Filter calculations
    readonly property string q: LauncherManager.searchQuery.trim().toLowerCase()
    readonly property string mode: LauncherManager.mode

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
            // Default top apps
            return list.slice(0, 30);
        }
        return list.map(a => ({ a, score: scoreApp(a, q) }))
                   .filter(x => x.score > 0)
                   .sort((a, b) => b.score - a.score || a.a.name.localeCompare(b.a.name))
                   .slice(0, 35)
                   .map(x => x.a);
    }

    // Unified list of items including headers and selectable rows
    readonly property var modelItems: {
        const out = [];
        const isAll = mode === "all";
        const isWin = mode === "windows";
        const isApps = mode === "apps";

        // 1. Calculator
        if (LauncherManager.calcResult) {
            out.push({
                isHeader: false,
                kind: "calc",
                data: LauncherManager.calcResult
            });
        }

        // 2. Open Windows
        if ((isAll || isWin) && filteredWindows.length > 0) {
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

        // 3. Applications
        if ((isAll || isApps) && filteredApps.length > 0) {
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

        return out;
    }

    // Map of selectable item indices in modelItems
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

    function activateCurrent() {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        const item = modelItems[targetModelIndex];
        if (!item || item.isHeader) return;

        if (item.kind === "calc") {
            LauncherManager.copyCalc(item.data.raw ?? item.data.result);
        } else if (item.kind === "window") {
            LauncherManager.focusWindow(item.data);
        } else if (item.kind === "app") {
            LauncherManager.launchApp(item.data);
        }
    }

    function launchNewInstanceForCurrent() {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        const item = modelItems[targetModelIndex];
        if (!item || item.isHeader) return;

        if (item.kind === "window") {
            LauncherManager.launchWindowApp(item.data);
        } else if (item.kind === "app") {
            LauncherManager.launchApp(item.data);
        } else if (item.kind === "calc") {
            LauncherManager.copyCalc(item.data.raw ?? item.data.result);
        }
    }

    function killCurrentWindow() {
        if (selectableIndices.length === 0) return;
        const targetModelIndex = selectableIndices[currentSelectable];
        const item = modelItems[targetModelIndex];
        if (item && item.kind === "window") {
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

    // Card background with rounded corners, translucent dark glass, and subtle border
    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(0.08, 0.09, 0.13, 0.82)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.16)

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
                font.pixelSize: 20
                color: {
                    if (LauncherManager.calcResult) return "#00E5FF";
                    if (root.mode === "windows") return "#A78BFA";
                    return Theme.accent;
                }
                text: {
                    if (LauncherManager.calcResult) return "\uF00EC"; // calculator 󰃬
                    if (root.mode === "windows") return "\uF04AC";    // window 󱂬
                    return "\uF0349";                                 // search 󰍉
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            // Text Input
            TextInput {
                id: input
                anchors.left: promptIcon.right
                anchors.leftMargin: 14
                anchors.right: modeTabs.left
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
                    visible: input.text.length === 0
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    text: {
                        if (root.mode === "windows") return "Search open windows...";
                        if (root.mode === "apps") return "Search applications...";
                        return "Search apps, open windows, or calculate (e.g. 25*4, 15% of 80)...";
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
                        if (shift || alt || ctrl) {
                            root.launchNewInstanceForCurrent();
                        } else {
                            root.activateCurrent();
                        }
                        event.accepted = true;
                    } else if (shift && event.key === Qt.Key_Delete) {
                        root.killCurrentWindow();
                        event.accepted = true;
                    }
                }
            }

            // Clear button
            Item {
                id: clearBtn
                anchors.right: modeTabs.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                visible: input.text.length > 0

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: clearMouse.containsMouse ? Theme.hover : "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: clearMouse.containsMouse ? Theme.fg : Theme.fgDim
                    font.family: Theme.fontFamily
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
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: [
                        { id: "all", label: "All" },
                        { id: "windows", label: "Windows (" + root.filteredWindows.length + ")" },
                        { id: "apps", label: "Apps" }
                    ]

                    Rectangle {
                        id: tabItem
                        required property var modelData
                        readonly property bool isActive: root.mode === modelData.id
                        height: 28
                        width: tabLabel.implicitWidth + 18
                        radius: 14
                        color: isActive ? Qt.rgba(255, 255, 255, 0.14) : (tabMouse.containsMouse ? Theme.hover : "transparent")
                        border.width: 1
                        border.color: isActive ? Qt.rgba(255, 255, 255, 0.22) : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 140 }
                        }

                        Text {
                            id: tabLabel
                            anchors.centerIn: parent
                            text: tabItem.modelData.label
                            color: tabItem.isActive ? Theme.fg : Theme.fgDim
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: tabItem.isActive ? Font.Bold : Font.Normal
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
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        // ---------- Results List ----------
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
                    height: isHeader ? 32 : (modelData.kind === "calc" ? 64 : 54)

                    // 1. SECTION HEADER
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
                                    color: delegateRoot.modelData.title.indexOf("WINDOWS") !== -1 ? "#A78BFA" : Theme.accent
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

                    // 2. SELECTABLE ITEMS (Calc, Window, App)
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
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const selIdx = root.selectableIndices.indexOf(delegateRoot.index);
                                    if (selIdx !== -1) {
                                        root.currentSelectable = selIdx;
                                    }
                                    root.activateCurrent();
                                }
                            }

                            // ---------- CALC ITEM ----------
                            Loader {
                                active: delegateRoot.modelData.kind === "calc"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 14

                                    // Calc Icon Box
                                    Rectangle {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 10
                                        color: Qt.rgba(0, 229, 255, 0.15)
                                        border.width: 1
                                        border.color: Qt.rgba(0, 229, 255, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uF00EC" // calc icon
                                            font.family: Theme.iconFamily
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

                                    // Action Badge
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

                            // ---------- WINDOW ITEM ----------
                            Loader {
                                active: delegateRoot.modelData.kind === "window"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    // App/Window Icon
                                    Item {
                                        Layout.preferredWidth: 34
                                        Layout.preferredHeight: 34

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
                                            text: "\uF04AC" // window glyph
                                            font.family: Theme.iconFamily
                                            font.pixelSize: 20
                                            color: "#A78BFA"
                                        }
                                    }

                                    // Title & Info
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: delegateRoot.modelData.data.title || "Window"
                                            color: delegateRoot.isSelected ? Theme.fg : Qt.rgba(1, 1, 1, 0.9)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: (delegateRoot.modelData.data.appid || "app") + " • " + (delegateRoot.modelData.data.monitor || "")
                                            color: Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Workspace Tag Badge
                                    Rectangle {
                                        Layout.preferredHeight: 22
                                        Layout.preferredWidth: tagLabel.implicitWidth + 12
                                        radius: 6
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

                                    // Focus Window Badge
                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: focusLabel.implicitWidth + 14
                                        radius: 6
                                        color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.08)

                                        Text {
                                            id: focusLabel
                                            anchors.centerIn: parent
                                            text: delegateRoot.isSelected ? "↵ Switch" : "Switch"
                                            color: delegateRoot.isSelected ? Theme.fg : Theme.fgDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: delegateRoot.isSelected
                                        }
                                    }

                                    // New Instance Badge
                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: newAppLabel.implicitWidth + 14
                                        radius: 6
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
                                            onClicked: {
                                                LauncherManager.launchWindowApp(delegateRoot.modelData.data);
                                            }
                                        }
                                    }
                                }
                            }

                            // ---------- APP ITEM ----------
                            Loader {
                                active: delegateRoot.modelData.kind === "app"
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    // App Icon
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
                                            text: "\uF0043" // app cube glyph
                                            font.family: Theme.iconFamily
                                            font.pixelSize: 20
                                            color: Theme.accent
                                        }
                                    }

                                    // Name & Description
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

                                    // Terminal badge if needed
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

                                    // Launch Badge
                                    Rectangle {
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: launchLabel.implicitWidth + 14
                                        radius: 6
                                        color: delegateRoot.isSelected ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.08)

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
                        }
                    }
                }
            }

            // Empty state placeholder
            Item {
                anchors.fill: parent
                visible: root.modelItems.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uF0349" // search icon
                        font.family: Theme.iconFamily
                        font.pixelSize: 28
                        color: Theme.fgFaint
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.q ? `No results found for "${root.q}"` : "Type to search or calculate..."
                        color: Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
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
                spacing: 16

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "↑↓"; font.pixelSize: 10; color: Theme.fgDim }
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
                    Text { text: "Open / Focus"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 44; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "⇧+↵"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "New App"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 26; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "Tab"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "Switch Mode"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 48; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
                        Text { anchors.centerIn: parent; text: "⇧+Del"; font.pixelSize: 9; color: Theme.fgDim }
                    }
                    Text { text: "Close Window"; color: Theme.fgDim; font.pixelSize: 11; font.family: Theme.fontFamily; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 26; height: 16; radius: 3; color: Qt.rgba(255, 255, 255, 0.1)
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
                text: "Spotlight Launcher"
                color: Theme.fgFaint
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }
    }
}
