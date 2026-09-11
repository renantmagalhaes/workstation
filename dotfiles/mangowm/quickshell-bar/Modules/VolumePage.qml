import QtQuick
import "../Config"
import "../Services"
import "../Widgets"

// Output and input volume plus device selection -- the island equivalent of
// right-clicking waybar's pulseaudio module.
//
// Reports its own implicitHeight so the panel grows and shrinks as the device
// lists open and close.
Item {
    id: root

    // "" | "output" | "input" -- only one list open at a time.
    property string openSection: ""

    implicitHeight: column.implicitHeight + Theme.panelPad * 2

    function toggle(section) {
        openSection = openSection === section ? "" : section;
    }

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.panelPad
        }
        spacing: 6

        // ---- Output ----------------------------------------------------------
        Text {
            text: "OUTPUT"
            color: Theme.fgFaint
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall - 2
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        VolumeSlider {
            width: parent.width
            value: Audio.volume
            muted: Audio.muted
            icon: Audio.icon
            readout: Audio.muted ? "off" : Audio.percent + "%"
            onRequested: value => Audio.setVolume(value)
            onMuteToggled: Audio.toggleMute()
        }

        AudioDeviceSelector {
            width: parent.width
            devices: Audio.outputs
            current: Audio.sink
            expanded: root.openSection === "output"
            onToggleRequested: root.toggle("output")
            onSelected: node => Audio.setOutput(node)
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.fgFaint
            opacity: 0.5
        }

        // ---- Input -----------------------------------------------------------
        Text {
            text: "INPUT"
            color: Theme.fgFaint
            font.family: Theme.fontFamily; renderType: Text.QtRendering
            font.pixelSize: Theme.fontSizeSmall - 2
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        VolumeSlider {
            width: parent.width
            value: Audio.micVolume
            muted: Audio.micMuted
            icon: Audio.micIcon
            readout: Audio.micMuted ? "off" : Audio.micPercent + "%"
            onRequested: value => Audio.setMicVolume(value)
            onMuteToggled: Audio.toggleMicMute()
        }

        AudioDeviceSelector {
            width: parent.width
            devices: Audio.inputs
            current: Audio.source
            expanded: root.openSection === "input"
            onToggleRequested: root.toggle("input")
            onSelected: node => Audio.setInput(node)
        }
    }
}
