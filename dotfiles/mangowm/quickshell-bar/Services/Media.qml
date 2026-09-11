pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The MPRIS player the bar should represent.
//
// State is pushed imperatively from per-player Connections rather than computed
// in a binding: a binding over `Mpris.players.values` only depends on the
// *list*, so it would never re-evaluate when an individual player starts or
// changes track.
Singleton {
    id: root

    property var active: null
    property bool hasPlayer: false
    property bool playing: false
    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string identity: ""
    property bool canNext: false
    property bool canPrevious: false

    // Every controllable, non-proxy player -- used by the page's picker so a
    // choice can be forced instead of relying on auto-selection.
    readonly property var players: (Mpris.players?.values ?? []).filter(p => p?.canControl && !isProxy(p))

    // MPRIS position does not emit on its own, so it is poked on a timer while
    // playing and read through a binding. Players that lie about support are
    // gated on lengthSupported/positionSupported.
    readonly property real duration: active?.lengthSupported ? Math.max(0, active.length) : 0
    readonly property real position: active?.positionSupported ? Math.max(0, active.position) : 0
    readonly property real progress: duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
    readonly property bool seekable: (active?.canSeek ?? false) && duration > 0

    function seek(fraction) {
        if (!seekable) return;
        active.position = Math.max(0, Math.min(1, fraction)) * duration;
    }

    function pick(player) {
        promote(player);
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

    // "Artist — Title", collapsing gracefully when a player exposes only one.
    readonly property string label: {
        if (!hasPlayer) return "";
        if (title && artist) return `${artist} — ${title}`;
        return title || artist || identity;
    }

    // playerctld registers itself on the bus as a player, but it is only a
    // proxy that mirrors whichever real player is current. Left in the list it
    // shows up as a duplicate of the thing already playing and the selection
    // can land on it, which makes the chip appear to jump between sources.
    function isProxy(player) {
        return (player?.dbusName ?? "").endsWith(".playerctld");
    }

    // Selection is driven by *transitions*, not by polling who happens to be
    // playing. A player that just started is what you are paying attention to,
    // so it takes the chip even if something else is still playing -- otherwise
    // a long-running player (Stremio) holds it forever and starting a YouTube
    // video changes nothing. Pausing deliberately does not hand the chip away,
    // which is what stops a pause from jumping to an unrelated player.
    function promote(player) {
        if (!player || !player.canControl || isProxy(player)) return;
        root.active = player;
        resolve();
    }

    function resolve() {
        const all = Mpris.players?.values ?? [];
        const usable = all.filter(p => p?.canControl && !isProxy(p));

        // Hold on to the current choice while it still exists; promote() is
        // what moves it. Only when it disappears do we look for a replacement,
        // preferring something that is actually playing.
        const keep = usable.indexOf(root.active) >= 0 ? root.active : null;
        const chosen = keep ?? usable.find(p => p.isPlaying) ?? usable[0] ?? null;

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

    // Send a bare MPRIS method to the active player.
    //
    // Quickshell's play()/pause()/togglePlaying() call the Play and Pause
    // methods, and some players -- Stremio among them -- advertise CanPlay and
    // CanPause but implement neither, responding only to PlayPause. Those calls
    // then fail silently. PlayPause is the one transport method essentially
    // every player gets right, so drive the toggle with it directly.
    function send(method) {
        const name = active?.dbusName;
        if (!name) return;
        Quickshell.execDetached(["busctl", "--user", "call", name, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", method]);
    }

    function toggle() {
        send("PlayPause");
    }

    function next() {
        if (canNext) send("Next");
    }

    // The idiomatic MPRIS previous: restart the track first, only skip back if
    // already near the beginning.
    function previous() {
        if (!active) return;
        if (active.canSeek && active.position > 8) {
            active.position = 0;
            return;
        }
        if (canPrevious) send("Previous");
    }

    Component.onCompleted: resolve()

    // Fan out to every player so any of them waking up re-resolves the choice.
    // Mpris itself exposes no "players changed" signal, so appearing and
    // disappearing players are picked up from the Instantiator's own hooks.
    Instantiator {
        model: Mpris.players

        // A player can appear already playing (open a tab that autoplays), in
        // which case no isPlaying transition ever fires for us to catch.
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
