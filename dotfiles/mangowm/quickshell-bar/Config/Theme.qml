pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ---- Palette -----------------------------------------------------------
    // Composed from the selected entry in Palettes plus the blur preference.
    // Nothing here is hardcoded so a new scheme needs no changes outside
    // Palettes.qml.
    readonly property var palette: Palettes.byId(Settings.theme)

    // Palette entries are hex strings. Assigning them to a `color` property is
    // what converts them; Qt.alpha() needs a real colour, not a string.
    readonly property color baseBg: palette.bg
    readonly property color baseBorder: palette.border

    readonly property color fg: palette.fg
    readonly property color fgDim: palette.fgDim
    readonly property color fgFaint: palette.fgFaint
    readonly property color accent: palette.accent

    // Background alpha is the whole difference between the solid and blurred
    // looks: with blur on, the compositor's backdrop blur shows through the
    // translucency; with it off the pill reads as a solid cutout.
    readonly property color islandBg: Qt.alpha(baseBg, Settings.blur ? palette.blurAlpha : palette.solidAlpha)
    readonly property color islandBorder: Qt.alpha(baseBorder, palette.borderAlpha)

    // Interaction states are derived from the foreground so they land correctly
    // on every scheme instead of assuming a black background.
    readonly property color hover: Qt.alpha(fg, 0.10)
    readonly property color pressed: Qt.alpha(fg, 0.18)
    readonly property color tint: Qt.alpha(fg, 0.07)
    readonly property color highlight: Qt.alpha(fg, 0.15)

    readonly property color urgent: palette.urgent
    readonly property color good: palette.good
    readonly property color warn: palette.warn

    // Workspace dot states
    readonly property color wsEmpty: palette.wsEmpty
    readonly property color wsOccupied: palette.wsOccupied
    readonly property color wsActive: palette.accent

    // Readable ink for text sitting on an accent-filled shape.
    readonly property color onAccent: foregroundFor(accent)

    function foregroundFor(candidate) {
        const luminance = 0.2126 * candidate.r + 0.7152 * candidate.g + 0.0722 * candidate.b;
        return luminance > 0.53 ? "#12121A" : "#FFFFFF";
    }

    // ---- Metrics -----------------------------------------------------------
    readonly property int islandHeight: 34

    // Squircle corners, not a pill: well short of islandHeight/2 so the shape
    // reads as "between a square and a rounded corner". `squircleExponent` is
    // the superellipse power -- 2 would be a plain circular round-rect.
    readonly property int islandRadius: 12
    readonly property real squircleExponent: 4.0

    // Radius for small inner chips (hover backgrounds, tray slots), kept in the
    // same family rather than fully round.
    readonly property int chipRadius: 9
    readonly property int islandPadH: 8      // inner padding, left/right
    readonly property int topMargin: 6       // gap between screen edge and pill
    readonly property int glowPad: 10        // room under the pill for the shadow
    readonly property int sectionSpacing: 4

    readonly property int capsuleHeight: islandHeight - 8
    readonly property int capsuleRadius: capsuleHeight / 2
    readonly property int capsulePadH: 10


    // Expanded pages. maxPanelHeight sizes the (transparent) layer surface, so
    // it must exceed the tallest page; it is never reserved as exclusive zone.
    readonly property int panelRadius: 20
    readonly property int panelPad: 14
    readonly property int maxPanelHeight: 460

    // The panel is detached from the pill and points back at whichever chip
    // opened it, so it reads as a popover rather than part of the bar.
    readonly property int panelGap: 8
    readonly property int tailHeight: 8
    readonly property int tailWidth: 20

    readonly property int calendarWidth: 316
    readonly property int calendarHeight: 340
    readonly property int volumePageWidth: 384
    // Floor only -- the audio page reports its own height, which grows when a
    // device list is expanded.
    readonly property int volumePageHeight: 150
    readonly property int mediaPageWidth: 380
    readonly property int mediaPageHeight: 96
    readonly property int systemPageWidth: 380
    readonly property int systemPageHeight: 252
    readonly property int controlPageWidth: 384
    // Floor only -- the page reports its own height as lists open.
    readonly property int controlPageHeight: 180
    readonly property int sessionPageWidth: 286
    readonly property int sessionPageHeight: 86

    // ---- Type --------------------------------------------------------------
    // Two families on purpose. Text is set in a UI sans -- a monospace coding
    // face is hard to read at bar sizes -- while every icon in the bar is a
    // Nerd Font glyph and has to stay on a font that actually contains them.
    readonly property string fontFamily: "Adwaita Sans"
    readonly property string iconFamily: "CaskaydiaCove Nerd Font"

    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    readonly property int iconSize: 14

    // ---- Motion ------------------------------------------------------------
    // The island's width animation is the signature effect: a soft overshoot so
    // it feels like it is stretching rather than snapping.
    readonly property int durSnappy: 180
    readonly property int durNormal: 280
    readonly property int durIsland: 420
    readonly property real overshoot: 1.15
}
