pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    PamAuth {
        id: pam

        onAuthenticated: {
            console.log("Authentication successful! Unlocking session...");
            unlockAnimation.start();
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: true

        surface: Component {
            LockSurface {
                lock: sessionLock
                pam: pam
            }
        }
    }

    SequentialAnimation {
        id: unlockAnimation

        PauseAnimation { duration: 100 }

        ScriptAction {
            script: unlockSession()
        }
    }

    function unlockSession() {
        sessionLock.locked = false;
        Quickshell.process.exit(0);
    }
}
