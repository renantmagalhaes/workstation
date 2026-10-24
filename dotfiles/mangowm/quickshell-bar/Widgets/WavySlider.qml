import QtQuick
import "../Config"

Item {
    id: root

    property real value: 0              // 0.0 to 1.0
    property bool playing: false
    property color color: Theme.accent
    property color trackColor: Theme.wsEmpty
    property real wheelStep: 0.02

    signal requested(real fraction)

    property real preview: value
    property bool dragging: false
    property bool awaiting: false

    readonly property real shown: dragging || awaiting ? preview : Math.max(0, Math.min(1, value))

    implicitHeight: 24

    onValueChanged: {
        if (!dragging && awaiting && Math.abs(value - preview) <= 0.02) {
            awaiting = false;
            confirmTimeout.stop();
        }
        if (!dragging && !awaiting) preview = value;
    }

    Timer {
        id: confirmTimeout
        interval: 700
        onTriggered: root.awaiting = false
    }

    property real wavePhase: 0
    property real waveAmplitude: playing && !dragging ? 2.5 : 0

    Behavior on waveAmplitude {
        NumberAnimation { duration: Theme.durNormal; easing.type: Easing.OutCubic }
    }

    NumberAnimation on wavePhase {
        running: root.playing && !root.dragging
        from: 0
        to: Math.PI * 2
        duration: 1800
        loops: Animation.Infinite
    }

    onWavePhaseChanged: canvas.requestPaint()
    onShownChanged: canvas.requestPaint()
    onWaveAmplitudeChanged: canvas.requestPaint()

    Canvas {
        id: canvas

        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;
            const midY = h / 2;

            ctx.clearRect(0, 0, w, h);
            if (w <= 0 || h <= 0) return;

            const activeW = Math.max(0, Math.min(w, w * root.shown));

            // Background inactive track
            ctx.beginPath();
            ctx.moveTo(activeW, midY);
            ctx.lineTo(w, midY);
            ctx.strokeStyle = root.trackColor;
            ctx.lineWidth = 4;
            ctx.lineCap = "round";
            ctx.stroke();

            // Active track (wavy when playing, straight when paused)
            if (activeW > 0) {
                ctx.beginPath();
                ctx.moveTo(0, midY);

                if (root.waveAmplitude > 0.1 && activeW > 12) {
                    const waveLength = 18; // Frequency
                    for (let x = 0; x <= activeW; x += 2) {
                        const wave = Math.sin((x / waveLength) * Math.PI * 2 - root.wavePhase) * root.waveAmplitude;
                        ctx.lineTo(x, midY + wave);
                    }
                } else {
                    ctx.lineTo(activeW, midY);
                }

                ctx.strokeStyle = root.color;
                ctx.lineWidth = 4;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // Draggable Knob
            const knobRadius = mouseArea.containsMouse || root.dragging ? 6 : 5;
            ctx.beginPath();
            ctx.arc(activeW, midY, knobRadius, 0, Math.PI * 2);
            ctx.fillStyle = Theme.fg;
            ctx.fill();
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateFromMouse(mouseX) {
            const fraction = Math.max(0, Math.min(1, mouseX / Math.max(1, width)));
            root.preview = fraction;
            root.awaiting = true;
            confirmTimeout.restart();
            root.requested(fraction);
        }

        onPressed: event => {
            root.dragging = true;
            updateFromMouse(event.x);
        }

        onPositionChanged: event => {
            if (root.dragging) updateFromMouse(event.x);
        }

        onReleased: {
            root.dragging = false;
        }

        onWheel: event => {
            const delta = event.angleDelta.y > 0 ? root.wheelStep : -root.wheelStep;
            const target = Math.max(0, Math.min(1, root.shown + delta));
            root.preview = target;
            root.awaiting = true;
            confirmTimeout.restart();
            root.requested(target);
        }
    }
}
