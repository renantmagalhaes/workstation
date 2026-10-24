pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Native freedesktop notification server using Quickshell.Services.Notifications.
// Replaces Mako with full in-process notification dispatching, rich card details,
// toast popups, actions, and real-time state tracking.
Singleton {
    id: root

    property var list: []
    readonly property int count: list.length
    readonly property bool hasUnread: count > 0

    property int popupVersion: 0
    readonly property var popups: {
        popupVersion;
        return list.filter(n => n && n.popup);
    }

    property bool dnd: false
    readonly property string icon: dnd ? "󰂛" : count > 0 ? "󰂚" : "󰂜"

    property var latestNotif: null
    property bool notifyAlertActive: false

    Timer {
        id: alertTimer
        interval: 4000
        onTriggered: {
            root.notifyAlertActive = false;
            root.latestNotif = null;
        }
    }

    function removeItem(item) {
        if (!item) return;
        item.popup = false;
        root.list = root.list.filter(n => n !== item);
        root.popupVersion++;
        if (root.latestNotif === item) {
            root.notifyAlertActive = false;
            root.latestNotif = null;
        }
        item.destroy();
    }

    function dismissAll() {
        for (const item of root.list.slice()) {
            item.popup = false;
            item.dismiss();
        }
        root.list = [];
        root.popupVersion++;
        root.notifyAlertActive = false;
        root.latestNotif = null;
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
        if (root.dnd) {
            for (const item of root.list) {
                item.popup = false;
            }
            root.popupVersion++;
            root.notifyAlertActive = false;
            root.latestNotif = null;
        }
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const nId = notif.id ? String(notif.id) : ("n_" + Date.now() + "_" + Math.floor(Math.random() * 1000));

            // Replace existing notification with the same ID if already in list
            const existing = root.list.find(n => n.notifId === nId);
            if (existing) {
                root.list = root.list.filter(n => n !== existing);
                existing.destroy();
            }

            const timeout = (notif.expireTimeout && notif.expireTimeout > 0) ? notif.expireTimeout : 5000;

            const item = notifComp.createObject(root, {
                rawNotif: notif,
                notifId: nId,
                summary: notif.summary ?? "",
                body: notif.body ?? "",
                appName: notif.appName && notif.appName.length > 0 ? notif.appName : "System",
                appIcon: notif.appIcon ?? "",
                image: notif.image ?? "",
                urgency: notif.urgency ?? 1,
                timeoutMs: timeout,
                popup: !root.dnd,
                time: new Date(),
                actions: (notif.actions ?? []).map(a => ({
                    identifier: a.identifier,
                    text: a.text,
                    invoke: () => a.invoke()
                }))
            });

            root.list = [item, ...root.list];
            root.popupVersion++;

            if (!root.dnd) {
                root.latestNotif = item;
                root.notifyAlertActive = true;
                alertTimer.restart();
            }
        }
    }

    Component {
        id: notifComp

        QtObject {
            id: item

            property var rawNotif
            property string notifId: ""
            property string summary: ""
            property string body: ""
            property string appName: ""
            property string appIcon: ""
            property string image: ""
            property int urgency: 1
            property var actions: []
            property date time: new Date()
            property string timeStr: "Just now"

            property bool popup: false
            property bool hovered: false
            property int timeoutMs: 5000

            onPopupChanged: root.popupVersion++

            readonly property Timer popupTimer: Timer {
                interval: item.timeoutMs > 0 ? item.timeoutMs : 5000
                running: item.popup && !item.hovered
                onTriggered: {
                    item.popup = false;
                }
            }

            function dismissPopup() {
                item.popup = false;
            }

            readonly property Timer ageTimer: Timer {
                interval: 20000
                running: true
                repeat: true
                onTriggered: item.updateAge()
            }

            function updateAge() {
                const diff = Date.now() - item.time.getTime();
                const mins = Math.floor(diff / 60000);
                if (mins < 1) {
                    item.timeStr = "Just now";
                } else if (mins < 60) {
                    item.timeStr = mins + "m ago";
                } else {
                    const hrs = Math.floor(mins / 60);
                    if (hrs < 24) {
                        item.timeStr = hrs + "h ago";
                    } else {
                        const days = Math.floor(hrs / 24);
                        item.timeStr = days + "d ago";
                    }
                }
            }

            function dismiss() {
                item.popup = false;
                if (rawNotif) {
                    try {
                        rawNotif.dismiss();
                    } catch (e) {}
                }
                root.removeItem(item);
            }

            function invokeAction(identifier) {
                if (actions) {
                    for (let i = 0; i < actions.length; i++) {
                        if (actions[i].identifier === identifier) {
                            try {
                                actions[i].invoke();
                            } catch (e) {}
                            break;
                        }
                    }
                }
                dismiss();
            }

            readonly property Connections _conn: Connections {
                target: item.rawNotif
                function onClosed() {
                    root.removeItem(item);
                }
            }
        }
    }
}
