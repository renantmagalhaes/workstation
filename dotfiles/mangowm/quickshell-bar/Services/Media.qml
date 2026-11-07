pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The MPRIS media player service for QuickShell.
//
// Manages media playback state and serves as the single source of truth for
// both the desktop bar UI and keyboard media shortcuts (via IPC).
// Selection is purely state-driven:
//   1. Actively playing player always takes precedence.
//   2. If paused, sticky retention of the player that has actual media loaded.
//   3. Players with no loaded media are never auto-selected.
//   4. Zero hardcoded player exclusions.
Singleton {
    id: root

    property var active: null
    property bool deliberate: false
    property bool hasPlayer: false
    property bool playing: false
    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string identity: ""
    property bool canNext: false
    property bool canPrevious: false

    // Filter out internal daemon proxy (playerctld) so it does not duplicate
    // real players on the bus. All real players (including KDE Connect) are kept.
    function isProxy(player) {
        return (player?.dbusName ?? "").endsWith(".playerctld");
    }

    function isKdeConnect(player) {
        if (!player) return false;
        const name = (player.dbusName ?? "").toLowerCase();
        const ident = (player.identity ?? "").toLowerCase();
        return name.includes("kdeconnect") || ident.includes("kde connect");
    }

    // Every controllable, real player on the bus
    readonly property var players: (Mpris.players?.values ?? []).filter(p => p?.canControl && !isProxy(p))

    // Position and seek support
    readonly property real duration: active?.lengthSupported ? Math.max(0, active.length) : 0
    readonly property real position: active?.positionSupported ? Math.max(0, active.position) : 0
    readonly property real progress: duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
    readonly property bool seekable: (active?.canSeek ?? false) && duration > 0

    function seek(fraction) {
        if (!seekable || !active) return;
        active.position = Math.max(0, Math.min(1, fraction)) * duration;
    }

    // Explicit user pick from the player picker UI
    function pick(player) {
        if (!player || !player.canControl || isProxy(player)) return;
        root.active = player;
        root.deliberate = true;
        resolve();
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0 || !isFinite(seconds)) return "0:00";
        const total = Math.floor(seconds);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = total % 60;
        const mm = h > 0 ? String(m).padStart(2, "0") : String(m);
        return (h > 0 ? `${h}:` : "") + `${mm}:${String(s).padStart(2, "0")}`;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.playing && root.seekable
        onTriggered: root.active?.positionChanged()
    }

    readonly property string label: {
        if (!hasPlayer) return "";
        if (title && artist) return `${artist} — ${title}`;
        return title || artist || identity;
    }

    // A player has playable media content if it is actively Playing,
    // or Paused with a valid non-empty track title.
    // Stopped players or players with empty metadata have no media.
    function hasContent(p) {
        if (!p) return false;
        if (p.isPlaying) return true;
        if (p.playbackState === MprisPlaybackState.Paused) {
            return (p.trackTitle ?? "").trim() !== "";
        }
        return false;
    }

    // Called whenever a player starts playing so it immediately gains focus
    function promote(player) {
        if (!player || !player.canControl || isProxy(player)) return;
        root.active = player;
        root.deliberate = true;
        resolve();
    }

    function resolve() {
        const usable = (Mpris.players?.values ?? []).filter(p => p?.canControl && !isProxy(p));
        const present = usable.indexOf(root.active) >= 0 ? root.active : null;

        // Keep current selection if user deliberately picked it, or if it still has content
        const keep = (root.deliberate && present) || (hasContent(present) ? present : null);

        // State-driven hierarchy:
        // 1. Sticky current player if it still has media
        // 2. Any player actively playing
        // 3. Any player paused with a loaded track
        // 4. Any present player
        // 5. Fallback to null (idle/no media)
        const chosen = keep
            ?? usable.find(p => p.isPlaying)
            ?? usable.find(hasContent)
            ?? present
            ?? null;

        root.deliberate = (root.deliberate && chosen === present) || (chosen?.isPlaying ?? false);
        root.active = chosen;
        root.hasPlayer = !!chosen;
        root.playing = chosen?.isPlaying ?? false;
        root.title = chosen?.trackTitle ?? "";
        root.artist = chosen?.trackArtist ?? "";
        root.artUrl = chosen?.trackArtUrl ?? "";
        root.identity = chosen?.identity ?? "";
        root.canNext = chosen?.canGoNext ?? false;
        root.canPrevious = chosen?.canGoPrevious ?? false;
    }

    // Direct MPRIS D-Bus method call
    function send(method) {
        const name = active?.dbusName;
        if (!name) return;
        Quickshell.execDetached(["busctl", "--user", "call", name, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", method]);
    }

    function toggle() {
        if (!active) {
            resolve();
        }
        send("PlayPause");
    }

    function play() { send("Play"); }
    function pause() { send("Pause"); }
    function stop() { send("Stop"); }

    function next() {
        if (canNext) send("Next");
    }

    function previous() {
        if (!active) return;
        if (active.canSeek && active.position > 8) {
            active.position = 0;
            return;
        }
        if (canPrevious) send("Previous");
    }

    Component.onCompleted: resolve()

    // IPC interface for keybindings and scripts to control the active player
    IpcHandler {
        target: "media"

        function toggle(): void {
            if (root.isKdeConnect(root.active)) return;
            root.toggle();
        }

        function playPause(): void {
            if (root.isKdeConnect(root.active)) return;
            root.toggle();
        }

        function play(): void {
            if (root.isKdeConnect(root.active)) return;
            root.play();
        }

        function pause(): void {
            if (root.isKdeConnect(root.active)) return;
            root.pause();
        }

        function stop(): void { root.stop(); }
        function next(): void { root.next(); }
        function previous(): void { root.previous(); }
    }

    // Watch for players appearing, disappearing, or updating state
    Instantiator {
        model: Mpris.players

        onObjectAdded: (index, object) => {
            const player = object?.modelData ?? null;
            if (player?.isPlaying) root.promote(player);
            else root.resolve();
        }
        onObjectRemoved: root.resolve()

        delegate: Connections {
            required property var modelData

            target: modelData
            ignoreUnknownSignals: true

            function onIsPlayingChanged() {
                if (modelData.isPlaying) root.promote(modelData);
                else root.resolve();
            }
            function onPlaybackStateChanged() { root.resolve(); }
            function onTrackTitleChanged() { root.resolve(); }
            function onTrackArtistChanged() { root.resolve(); }
            function onTrackArtUrlChanged() { root.resolve(); }
            function onPostTrackChanged() { root.resolve(); }
            function onCanGoNextChanged() { root.resolve(); }
            function onCanGoPreviousChanged() { root.resolve(); }
        }
    }
}
