pragma Singleton

import QtQuick
import Quickshell

// Named colour schemes for the island.
//
// A palette is plain data: base colours plus the two alphas its background uses
// when blur is off (near-opaque, reads as a solid cutout) and on (translucent,
// so the compositor's backdrop blur shows through). Theme.qml composes the
// actual tokens from these, so adding a scheme means adding one entry here and
// nothing else.
Singleton {
    id: root

    readonly property var list: [
        {
            id: "obsidian",
            name: "Obsidian",
            note: "Near-black, white accent",
            bg: "#000000",
            solidAlpha: 0.95,
            blurAlpha: 0.55,
            border: "#FFFFFF",
            borderAlpha: 0.12,
            fg: "#FFFFFF",
            fgDim: "#8E8E93",
            fgFaint: "#48484A",
            accent: "#FFFFFF",
            urgent: "#FF453A",
            good: "#30D158",
            warn: "#F4C46B",
            wsEmpty: "#3A3A3C",
            wsOccupied: "#8E8E93"
        },
        {
            id: "odyssey",
            name: "Odyssey",
            note: "Lighter slate, violet accent",
            bg: "#202027",
            solidAlpha: 0.96,
            blurAlpha: 0.62,
            border: "#48464F",
            borderAlpha: 0.85,
            fg: "#E6E1E9",
            fgDim: "#C9C5CF",
            fgFaint: "#78757F",
            accent: "#C7C3FF",
            urgent: "#FFB4AB",
            good: "#8BD5A5",
            warn: "#F4C46B",
            wsEmpty: "#3A3942",
            wsOccupied: "#928F99"
        },
        {
            id: "mocha",
            name: "Catppuccin",
            note: "Mocha, lavender accent",
            bg: "#1E1E2E",
            solidAlpha: 0.96,
            blurAlpha: 0.62,
            border: "#45475A",
            borderAlpha: 0.9,
            fg: "#CDD6F4",
            fgDim: "#A6ADC8",
            fgFaint: "#6C7086",
            accent: "#B4BEFE",
            urgent: "#F38BA8",
            good: "#A6E3A1",
            warn: "#F9E2AF",
            wsEmpty: "#45475A",
            wsOccupied: "#9399B2"
        },
        {
            id: "nord",
            name: "Nord",
            note: "Polar night, frost accent",
            bg: "#2E3440",
            solidAlpha: 0.96,
            blurAlpha: 0.62,
            border: "#4C566A",
            borderAlpha: 0.9,
            fg: "#ECEFF4",
            fgDim: "#D8DEE9",
            fgFaint: "#6C7A93",
            accent: "#88C0D0",
            urgent: "#BF616A",
            good: "#A3BE8C",
            warn: "#EBCB8B",
            wsEmpty: "#434C5E",
            wsOccupied: "#7B88A1"
        },
        {
            id: "gruvbox",
            name: "Gruvbox",
            note: "Warm dark, amber accent",
            bg: "#1D2021",
            solidAlpha: 0.96,
            blurAlpha: 0.6,
            border: "#504945",
            borderAlpha: 0.9,
            fg: "#D4BE98",
            fgDim: "#A89984",
            fgFaint: "#6B5F52",
            accent: "#E78A4E",
            urgent: "#EA6962",
            good: "#A9B665",
            warn: "#D8A657",
            wsEmpty: "#3C3836",
            wsOccupied: "#928374"
        },
        {
            id: "rose",
            name: "Rosé Pine",
            note: "Muted plum, rose accent",
            bg: "#191724",
            solidAlpha: 0.96,
            blurAlpha: 0.62,
            border: "#403D52",
            borderAlpha: 0.9,
            fg: "#E0DEF4",
            fgDim: "#908CAA",
            fgFaint: "#5B5677",
            accent: "#EBBCBA",
            urgent: "#EB6F92",
            good: "#9CCFD8",
            warn: "#F6C177",
            wsEmpty: "#403D52",
            wsOccupied: "#6E6A86"
        }
    ]

    readonly property var fallback: list[0]

    function byId(id) {
        return list.find(p => p.id === id) ?? fallback;
    }
}
