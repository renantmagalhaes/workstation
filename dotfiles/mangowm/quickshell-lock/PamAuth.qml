pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Item {
    id: root

    property string buffer: ""
    property bool active: passwd.active
    property bool failed: false
    property string errorMessage: ""

    signal authenticated()
    signal failedAuth(string msg)

    function handleKey(event) {
        if (root.active)
            return;

        // Esc clears the typed buffer
        if (event.key === Qt.Key_Escape) {
            root.buffer = "";
            root.failed = false;
            root.errorMessage = "";
            return;
        }

        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.buffer.length === 0)
                return;
            root.startAuth();
        } else if (event.key === Qt.Key_Backspace) {
            if (event.modifiers & Qt.ControlModifier) {
                root.buffer = "";
            } else if (root.buffer.length > 0) {
                root.buffer = root.buffer.slice(0, -1);
            }
            root.failed = false;
            root.errorMessage = "";
        } else if (event.text && event.text.length > 0) {
            if (/^[^\x00-\x1F\x7F-\x9F]+$/.test(event.text)) {
                root.buffer += event.text;
                root.failed = false;
                root.errorMessage = "";
            }
        }
    }

    function startAuth() {
        if (passwd.active || root.buffer.length === 0)
            return;
        root.failed = false;
        root.errorMessage = "";
        passwd.start();
    }

    Timer {
        id: failResetTimer
        interval: 3000
        onTriggered: {
            root.failed = false;
            root.errorMessage = "";
        }
    }

    PamContext {
        id: passwd

        config: "login"
        configDirectory: "/usr/lib/pam.d"

        onMessageChanged: {
            if (message && message.length > 0 && !message.startsWith("Password")) {
                root.errorMessage = message;
            }
        }

        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.buffer);
                root.buffer = "";
            }
        }

        onCompleted: res => {
            if (res === PamResult.Success) {
                root.failed = false;
                root.errorMessage = "";
                root.authenticated();
            } else {
                root.failed = true;
                root.errorMessage = root.errorMessage || "Incorrect password";
                root.buffer = "";
                failResetTimer.restart();
                root.failedAuth(root.errorMessage);
            }
        }
    }
}
