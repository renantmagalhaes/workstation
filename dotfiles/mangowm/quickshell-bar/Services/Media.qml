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

    function resolve() {
        const all = Mpris.players?.values ?? [];
        const usable = all.filter(p => p?.canControl && !isProxy(p));

        // Whatever we were already showing, if it is still around.
        const keep = usable.indexOf(root.active) >= 0 ? root.active : null;
        const playingNow = usable.find(p => p.isPlaying) ?? null;

        // Prefer something actually playing, but never drift off the current
        // player merely because it was paused. Falling back to usable[0] on
        // every pause handed the chip to whichever unrelated player happened
        // to be first in the list.
        let chosen;
        if (keep && keep.isPlaying)
            chosen = keep;
        else if (playingNow)
            chosen = playingNow;
        else
            chosen = keep ?? usable[0] ?? null;

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

        onObjectAdded: root.resolve()
        onObjectRemoved: root.resolve()

        delegate: Connections {
            required property var modelData

            target: modelData
            ignoreUnknownSignals: true

            function onIsPlayingChanged() { root.resolve(); }
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
