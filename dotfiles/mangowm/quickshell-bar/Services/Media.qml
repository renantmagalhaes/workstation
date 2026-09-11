pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The MPRIS player the bar should represent.
//
// Several players are usually registered at once (a browser tab plus a desktop
// app), so prefer one that is actually playing. State is pushed imperatively
// from per-player Connections rather than computed in a binding: a binding over
// `Mpris.players.values` only depends on the *list*, so it would never
// re-evaluate when an individual player starts or changes track.
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

    function resolve() {
        const all = Mpris.players?.values ?? [];
        const usable = all.filter(p => p?.canControl);
        const chosen = usable.find(p => p.isPlaying) ?? usable[0] ?? null;

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

    function toggle() {
        if (active?.canTogglePlaying) active.togglePlaying();
    }

    function next() {
        if (active?.canGoNext) active.next();
    }

    // The idiomatic MPRIS previous: restart the track first, only skip back if
    // already near the beginning.
    function previous() {
        if (!active) return;
        if (active.position > 8 && active.canSeek) {
            active.position = 0;
            return;
        }
        if (active.canGoPrevious) active.previous();
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
