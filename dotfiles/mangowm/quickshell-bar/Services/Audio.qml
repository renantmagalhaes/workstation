pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Default sink/source plus the list of selectable devices.
//
// Everything needs a live PwObjectTracker: without one a node's audio
// properties and description stay unbound, so volumes read as 0 and device
// names come back empty.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool ready: sink?.ready ?? false

    // ---- Output ------------------------------------------------------------
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: {
        if (muted || percent === 0) return "󰝟";
        if (percent < 34) return "󰕿";
        if (percent < 67) return "󰖀";
        return "󰕾";
    }

    function setVolume(value) {
        if (!sink?.audio) return;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function step(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (!sink?.audio) return;
        sink.audio.muted = !sink.audio.muted;
    }

    // ---- Input -------------------------------------------------------------
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property int micPercent: Math.round(micVolume * 100)

    readonly property string micIcon: micMuted || micPercent === 0 ? "󰍭" : "󰍬"

    function setMicVolume(value) {
        if (!source?.audio) return;
        source.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMicMute() {
        if (!source?.audio) return;
        source.audio.muted = !source.audio.muted;
    }

    // ---- Devices -----------------------------------------------------------
    // isStream excludes per-application streams (a browser tab's own volume),
    // leaving only real cards and endpoints.
    readonly property var allNodes: Pipewire.nodes?.values ?? []
    readonly property var outputs: allNodes.filter(n => n?.audio && n.isSink && !n.isStream)
    readonly property var inputs: allNodes.filter(n => n?.audio && !n.isSink && !n.isStream)

    function displayName(node) {
        if (!node) return "";
        return node.nickname || node.description || node.name || "";
    }

    function setOutput(node) {
        if (node) Pipewire.preferredDefaultAudioSink = node;
    }

    function setInput(node) {
        if (node) Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: root.outputs.concat(root.inputs)
    }
}
