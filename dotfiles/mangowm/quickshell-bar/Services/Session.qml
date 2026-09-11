pragma Singleton

import Quickshell

// Session actions. Commands are taken verbatim from the wlogout layout this
// replaces (waybar/extra/wlogout/layout).
Singleton {
    id: root

    readonly property var actions: [
        {
            id: "lock",
            label: "Lock",
            icon: "󰌾",
            command: ["hyprlock"],
            confirm: false,
            destructive: false
        },
        {
            id: "logout",
            label: "Log out",
            icon: "󰍃",
            // $XDG_SESSION_ID has to be expanded by a shell.
            command: ["sh", "-c", "loginctl kill-session \"$XDG_SESSION_ID\""],
            confirm: true,
            destructive: false
        },
        {
            id: "reboot",
            label: "Restart",
            icon: "󰜉",
            command: ["systemctl", "reboot"],
            confirm: true,
            destructive: false
        },
        {
            id: "shutdown",
            label: "Shut down",
            icon: "󰐥",
            command: ["systemctl", "poweroff"],
            confirm: true,
            destructive: true
        }
    ]

    function run(action) {
        if (!action?.command) return;
        Quickshell.execDetached(action.command);
    }
}
