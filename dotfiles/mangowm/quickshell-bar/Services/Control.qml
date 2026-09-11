pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// State and actions for the control centre.
//
// Backed by scripts/control.sh rather than Quickshell.Networking /
// Quickshell.Bluetooth: those modules exist in this build but report nothing
// here (zero network devices, null bluetooth adapter) despite NetworkManager
// and bluez being active. If a later Quickshell fixes them, the tiles can move
// over without the UI changing.
Singleton {
    id: root

    property bool wifiRadio: false
    property string wifiDevice: ""
    property string wifiState: ""
    property string wifiSsid: ""

    property string ethDevice: ""
    property string ethState: ""

    property bool btPowered: false
    property var btDevices: []

    property bool dnd: false
    property string profile: ""

    property var wifiNetworks: []
    // A scan takes a few seconds; without this the list reads
    // "No networks found" while it is still working.
    property bool scanning: false

    // Idle inhibit is kept here so a single service backs every tile. The
    // IdleInhibitor object itself has to be attached to the bar's window, so it
    // lives in Bar.qml and just reads this flag.
    property bool keepAwake: false

    readonly property var profiles: ["performance", "balanced", "power-saver"]

    readonly property bool ethConnected: ethState === "connected"
    readonly property bool wifiConnected: wifiSsid !== ""
    readonly property var btConnectedDevices: (btDevices ?? []).filter(d => d.connected)

    readonly property string networkSummary: {
        if (ethConnected) return ethDevice;
        if (wifiConnected) return wifiSsid;
        if (!wifiRadio) return "off";
        return "disconnected";
    }

    readonly property string btSummary: {
        if (!btPowered) return "off";
        const connected = btConnectedDevices;
        if (connected.length === 1) return connected[0].name;
        if (connected.length > 1) return `${connected.length} connected`;
        return "on";
    }

    function toggleWifi() {
        act(["wifi", wifiRadio ? "off" : "on"]);
    }

    function toggleBt() {
        act(["bt", btPowered ? "off" : "on"]);
    }

    function toggleDnd() {
        act(["dnd", dnd ? "off" : "on"]);
    }

    function toggleKeepAwake() {
        keepAwake = !keepAwake;
    }

    function cycleProfile() {
        const index = profiles.indexOf(profile);
        act(["profile", profiles[(index + 1) % profiles.length]]);
    }

    function toggleBtDevice(device) {
        if (!device?.mac) return;
        act([device.connected ? "bt-disconnect" : "bt-connect", device.mac]);
    }

    function connectWifi(ssid) {
        if (ssid) act(["wifi-connect", ssid]);
    }

    function scanWifi() {
        scanning = true;
        scanGuard.restart();
        lister.running = true;
    }

    Timer {
        id: scanGuard
        interval: 12000
        onTriggered: root.scanning = false
    }

    function act(args) {
        runner.running = false;
        runner.command = ["bash", Paths.script("control.sh")].concat(args);
        runner.running = true;
        // bluetoothctl and nmcli take a moment to settle, so nudge the poll
        // rather than waiting out the full interval.
        settle.restart();
    }

    Process {
        id: runner
    }

    Timer {
        id: settle
        interval: 1200
        onTriggered: probe.running = true
    }

    Process {
        id: probe
        command: ["bash", Paths.script("control.sh")]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                let parsed;
                try {
                    parsed = JSON.parse(data);
                } catch (e) {
                    return;
                }

                root.wifiRadio = parsed.wifi?.radio === true;
                root.wifiDevice = parsed.wifi?.device ?? "";
                root.wifiState = parsed.wifi?.state ?? "";
                root.wifiSsid = parsed.wifi?.ssid ?? "";
                root.ethDevice = parsed.eth?.device ?? "";
                root.ethState = parsed.eth?.state ?? "";
                root.btPowered = parsed.bt?.powered === true;
                root.btDevices = parsed.bt?.devices ?? [];
                root.dnd = parsed.dnd === true;
                root.profile = parsed.profile ?? "";
            }
        }
    }

    Process {
        id: lister
        command: ["bash", Paths.script("control.sh"), "wifi-list"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                try {
                    root.wifiNetworks = JSON.parse(data) ?? [];
                } catch (e) {}
                root.scanning = false;
                scanGuard.stop();
            }
        }
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
