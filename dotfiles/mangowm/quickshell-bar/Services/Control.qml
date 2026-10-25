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
    property bool ethCarrier: false
    property int ethSpeed: 0
    property string ethMac: ""
    property string ethIp: ""
    property string ethGateway: ""
    property string ethModel: ""
    property string ethUuid: ""

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
    readonly property string ethSpeedText: {
        if (!ethCarrier || ethSpeed <= 0) return "";
        if (ethSpeed >= 1000) return `${(ethSpeed / 1000).toFixed(0)} Gbps`;
        return `${ethSpeed} Mbps`;
    }
    readonly property bool wifiConnected: wifiSsid !== ""
    readonly property var btConnectedDevices: (btDevices ?? []).filter(d => d.connected)

    readonly property string networkSummary: {
        if (ethConnected) {
            return ethSpeedText !== "" ? `${ethDevice} · ${ethSpeedText}` : ethDevice;
        }
        if (wifiConnected) return wifiSsid;
        if (ethCarrier) return `${ethDevice} · cable plugged`;
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

    property int _pollCount: 0

    onWifiRadioChanged: {
        if (wifiRadio) {
            scanWifi();
        } else {
            wifiNetworks = [];
        }
    }

    Component.onCompleted: {
        scanWifi();
    }

    function toggleEth(device) {
        act(["eth-toggle", device ?? ethDevice]);
    }

    function connectEth(device) {
        act(["eth-connect", device ?? ethDevice]);
    }

    function disconnectEth(device) {
        act(["eth-disconnect", device ?? ethDevice]);
    }

    function editConnection(uuidOrDev) {
        act(["edit-connection", uuidOrDev ?? ethUuid ?? ethDevice]);
    }

    function openEditor() {
        act(["open-editor"]);
    }

    function copyToClipboard(text) {
        if (!text) return;
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | wl-copy', "sh", text]);
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
        if (!wifiRadio && wifiDevice === "") return;
        scanning = true;
        scanGuard.restart();
        if (lister.running) {
            lister.running = false;
        }
        lister.running = true;
    }

    Timer {
        id: scanGuard
        interval: 10000
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
        onTriggered: {
            probe.running = false;
            probe.running = true;
            if (root.wifiRadio && !root.scanning) {
                root.scanWifi();
            }
        }
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
                root.ethCarrier = parsed.eth?.carrier === true;
                root.ethSpeed = parsed.eth?.speed ? parseInt(parsed.eth.speed) : 0;
                root.ethMac = parsed.eth?.mac ?? "";
                root.ethIp = parsed.eth?.ip ?? "";
                root.ethGateway = parsed.eth?.gateway ?? "";
                root.ethModel = parsed.eth?.model ?? "";
                root.ethUuid = parsed.eth?.uuid ?? "";
                root.btPowered = parsed.bt?.powered === true;
                root.btDevices = parsed.bt?.devices ?? [];
                root.dnd = parsed.dnd === true;
                root.profile = parsed.profile ?? "";

                if (root.wifiRadio && (root.wifiNetworks.length === 0 || root.wifiNetworks === null) && !root.scanning) {
                    root.scanWifi();
                }
            }
        }
    }

    Process {
        id: lister
        command: ["bash", Paths.script("control.sh"), "wifi-list"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    try {
                        const parsed = JSON.parse(text);
                        if (Array.isArray(parsed)) {
                            root.wifiNetworks = parsed;
                        }
                    } catch (e) {
                        console.warn("Failed to parse wifi networks:", e);
                    }
                }
                root.scanning = false;
                scanGuard.stop();
            }
        }

        onExited: {
            root.scanning = false;
            scanGuard.stop();
        }
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            probe.running = false;
            probe.running = true;
            root._pollCount++;
            if (root._pollCount % 3 === 0 && root.wifiRadio && !root.scanning) {
                root.scanWifi();
            }
        }
    }
}
