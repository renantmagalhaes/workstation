pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ---- Palette -----------------------------------------------------------
    // "Dynamic Island": a near-opaque true-black pill that reads as a physical
    // cutout in the screen rather than a translucent panel. Everything else is
    // greyscale so colour is reserved for state (urgent / muted / active).
    readonly property color islandBg: "#F2000000"      // 95% black
    readonly property color islandBorder: "#1FFFFFFF"  // 12% white hairline
    readonly property color glow: "#CC000000"

    readonly property color fg: "#FFFFFF"
    readonly property color fgDim: "#8E8E93"            // iOS secondaryLabel (dark)
    readonly property color fgFaint: "#48484A"

    readonly property color hover: "#1AFFFFFF"
    readonly property color pressed: "#2EFFFFFF"

    readonly property color urgent: "#FF453A"           // iOS systemRed (dark)
    readonly property color good: "#30D158"             // iOS systemGreen (dark)

    // Workspace dot states
    readonly property color wsEmpty: "#3A3A3C"
    readonly property color wsOccupied: "#8E8E93"
    readonly property color wsActive: "#FFFFFF"

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

    readonly property int bottomGap: 4       // breathing room under the reserved strip

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
    readonly property int sessionPageWidth: 286
    readonly property int sessionPageHeight: 86

    // ---- Type --------------------------------------------------------------
    readonly property string fontFamily: "CaskaydiaCove Nerd Font"
    readonly property int fontSize: 12
    readonly property int fontSizeSmall: 10
    readonly property int iconSize: 14

    // ---- Motion ------------------------------------------------------------
    // The island's width animation is the signature effect: a soft overshoot so
    // it feels like it is stretching rather than snapping.
    readonly property int durSnappy: 180
    readonly property int durNormal: 280
    readonly property int durIsland: 420
    readonly property real overshoot: 1.15
}
