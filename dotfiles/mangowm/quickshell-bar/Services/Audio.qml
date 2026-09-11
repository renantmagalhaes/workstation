pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Thin wrapper over the default Pipewire sink so widgets don't each need their
// own PwObjectTracker (without a tracker the node's audio properties stay unbound).
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink?.ready ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: {
        if (muted || percent === 0) return "󰝟";
        if (percent < 34) return "󰕿";
        if (percent < 67) return "󰖀";
        return "󰕾";
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
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
}
