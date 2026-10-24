pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    anchors.fill: parent

    // Whispered, barely-visible PCB traces (revealed primarily when signals travel through them)
    property color traceColor: Qt.rgba(0.20, 0.45, 0.42, 0.045)  // Very faint 4.5% opacity
    property color padColor: Qt.rgba(0.35, 0.75, 0.65, 0.07)     // Faint micro-vias
    property real traceWidth: 1.0

    // Palette of electrical signal bursts
    readonly property var signalPalette: [
        "#00E5FF", // Electric Cyan
        "#78FFB4", // Neon Mint
        "#64FFDA", // Electric Teal
        "#80D8FF", // Ice Blue
        "#C084FC"  // Electric Violet
    ]

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property var tracks: []
        property var vias: []
        property var pulses: []
        property bool initialized: false

        // Procedural organic PCB track generation
        function initCircuit() {
            const w = width;
            const h = height;
            if (w <= 100 || h <= 100) return;

            const gridSize = 28;
            const cols = Math.floor(w / gridSize);
            const rows = Math.floor(h / gridSize);

            const newTracks = [];
            const newVias = [];
            const viaMap = {};

            function getViaKey(gx, gy) {
                return gx + "_" + gy;
            }

            function registerVia(gx, gy, r) {
                const key = getViaKey(gx, gy);
                if (!viaMap[key]) {
                    const via = { x: gx * gridSize, y: gy * gridSize, r: r || 3.0 };
                    viaMap[key] = via;
                    newVias.push(via);
                }
            }

            // Pseudo-random pseudo-organic trace routing
            // We generate 55 independent, randomized circuit traces
            const traceCount = 55;

            // 8 possible grid routing directions (ortho + 45 deg chamfers)
            const dirSteps = [
                { dx: 1, dy: 0 },
                { dx: -1, dy: 0 },
                { dx: 0, dy: 1 },
                { dx: 0, dy: -1 },
                { dx: 1, dy: 1 },
                { dx: -1, dy: 1 },
                { dx: 1, dy: -1 },
                { dx: -1, dy: -1 }
            ];

            for (let t = 0; t < traceCount; t++) {
                // Random starting position on grid
                let gx = Math.floor(Math.random() * (cols - 2)) + 1;
                let gy = Math.floor(Math.random() * (rows - 2)) + 1;

                // Mark start via
                registerVia(gx, gy, 3.2);

                const pts = [{ x: gx * gridSize, y: gy * gridSize }];
                const numSegments = Math.floor(Math.random() * 5) + 3; // 3 to 7 segments
                let curDir = Math.floor(Math.random() * dirSteps.length);

                for (let s = 0; s < numSegments; s++) {
                    const stepLen = Math.floor(Math.random() * 4) + 2; // 2 to 5 grid cells
                    const dir = dirSteps[curDir];

                    const nextGx = Math.max(1, Math.min(cols - 1, gx + dir.dx * stepLen));
                    const nextGy = Math.max(1, Math.min(rows - 1, gy + dir.dy * stepLen));

                    if (nextGx === gx && nextGy === gy) break;

                    gx = nextGx;
                    gy = nextGy;
                    pts.push({ x: gx * gridSize, y: gy * gridSize });

                    // Intermediate via occasionally
                    if (Math.random() < 0.35) {
                        registerVia(gx, gy, 2.5);
                    }

                    // Turn: pick a new direction with 45 or 90 degree deviation
                    if (Math.random() < 0.65) {
                        curDir = (curDir + (Math.random() < 0.5 ? 1 : -1) + dirSteps.length) % dirSteps.length;
                    } else {
                        curDir = (curDir + (Math.random() < 0.5 ? 2 : -2) + dirSteps.length) % dirSteps.length;
                    }
                }

                // End via
                registerVia(gx, gy, 3.5);

                // Calculate cumulative segment lengths
                let totalLen = 0;
                for (let j = 0; j < pts.length - 1; j++) {
                    const dx = pts[j + 1].x - pts[j].x;
                    const dy = pts[j + 1].y - pts[j].y;
                    pts[j].segLen = Math.sqrt(dx * dx + dy * dy);
                    totalLen += pts[j].segLen;
                }
                pts.totalLength = totalLen;

                if (pts.totalLength > 40) {
                    newTracks.push(pts);
                }
            }

            tracks = newTracks;
            vias = newVias;

            // Generate active electrical pulses
            const newPulses = [];
            const pulseCount = 32;

            for (let p = 0; p < pulseCount; p++) {
                const trackIdx = Math.floor(Math.random() * tracks.length);
                const colIdx = Math.floor(Math.random() * root.signalPalette.length);
                newPulses.push({
                    trackIdx: trackIdx,
                    progress: Math.random(),
                    speed: 0.15 + Math.random() * 0.28,    // fraction of track per second
                    direction: Math.random() > 0.5 ? 1 : -1,
                    tailLen: 45 + Math.random() * 55,      // tail length in pixels
                    color: root.signalPalette[colIdx],
                    width: 1.8 + Math.random() * 1.2,
                    alive: true,
                    delay: Math.random() * 3.0             // initial staggered spawn
                });
            }

            pulses = newPulses;
            initialized = true;
        }

        onWidthChanged: { initCircuit(); requestPaint(); }
        onHeightChanged: { initCircuit(); requestPaint(); }

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;

            ctx.clearRect(0, 0, w, h);
            if (!initialized || tracks.length === 0) return;

            // 1. Draw ultra-subtle PCB traces (barely visible background structure)
            ctx.lineWidth = root.traceWidth;
            ctx.strokeStyle = root.traceColor;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            for (let t = 0; t < tracks.length; t++) {
                const pts = tracks[t];
                ctx.beginPath();
                ctx.moveTo(pts[0].x, pts[0].y);
                for (let i = 1; i < pts.length; i++) {
                    ctx.lineTo(pts[i].x, pts[i].y);
                }
                ctx.stroke();
            }

            // 2. Draw faint micro via pads
            ctx.fillStyle = Qt.rgba(0.04, 0.08, 0.10, 0.25);
            ctx.strokeStyle = root.padColor;
            ctx.lineWidth = 1.0;

            for (let v = 0; v < vias.length; v++) {
                const via = vias[v];
                ctx.beginPath();
                ctx.arc(via.x, via.y, via.r, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();

                // Tiny center drill hole
                ctx.beginPath();
                ctx.arc(via.x, via.y, via.r * 0.38, 0, Math.PI * 2);
                ctx.fillStyle = Qt.rgba(0.35, 0.75, 0.65, 0.12);
                ctx.fill();
                ctx.fillStyle = Qt.rgba(0.04, 0.08, 0.10, 0.25);
            }

            // 3. Helper to interpolate coordinate along track at given distance
            function getPointAtDist(pts, dist) {
                if (dist <= 0) return { x: pts[0].x, y: pts[0].y };
                if (dist >= pts.totalLength) return { x: pts[pts.length - 1].x, y: pts[pts.length - 1].y };

                let cur = 0;
                for (let i = 0; i < pts.length - 1; i++) {
                    const segLen = pts[i].segLen;
                    if (cur + segLen >= dist) {
                        const ratio = (dist - cur) / segLen;
                        return {
                            x: pts[i].x + (pts[i + 1].x - pts[i].x) * ratio,
                            y: pts[i].y + (pts[i + 1].y - pts[i].y) * ratio
                        };
                    }
                    cur += segLen;
                }
                return { x: pts[pts.length - 1].x, y: pts[pts.length - 1].y };
            }

            // 4. Draw moving electrical signal pulses
            for (let p = 0; p < pulses.length; p++) {
                const pulse = pulses[p];
                if (pulse.delay > 0) continue; // Waiting to spawn

                const pts = tracks[pulse.trackIdx];
                if (!pts || !pts.totalLength) continue;

                const effectiveProgress = pulse.direction === 1 ? pulse.progress : (1.0 - pulse.progress);
                const headDist = effectiveProgress * pts.totalLength;
                const tailDist = pulse.direction === 1
                    ? Math.max(0, headDist - pulse.tailLen)
                    : Math.min(pts.totalLength, headDist + pulse.tailLen);

                const headPt = getPointAtDist(pts, headDist);
                const col = pulse.color;

                // A. Draw fading trail
                const steps = 5;
                const distSpan = headDist - tailDist;

                ctx.lineWidth = pulse.width;
                ctx.lineCap = "round";

                for (let s = 0; s < steps; s++) {
                    const d0 = tailDist + distSpan * (s / steps);
                    const d1 = tailDist + distSpan * ((s + 1) / steps);
                    const p0 = getPointAtDist(pts, d0);
                    const p1 = getPointAtDist(pts, d1);

                    ctx.beginPath();
                    ctx.moveTo(p0.x, p0.y);
                    ctx.lineTo(p1.x, p1.y);

                    const alpha = ((s + 1) / steps) * 0.85;
                    ctx.strokeStyle = col;
                    ctx.globalAlpha = alpha;
                    ctx.stroke();
                }
                ctx.globalAlpha = 1.0;

                // B. Outer glow halo around head
                ctx.beginPath();
                ctx.arc(headPt.x, headPt.y, pulse.width + 4.5, 0, Math.PI * 2);
                ctx.fillStyle = col;
                ctx.globalAlpha = 0.28;
                ctx.fill();

                // C. White-hot electrical spark core
                ctx.beginPath();
                ctx.arc(headPt.x, headPt.y, pulse.width * 0.75 + 1.0, 0, Math.PI * 2);
                ctx.fillStyle = "#FFFFFF";
                ctx.globalAlpha = 0.95;
                ctx.fill();
                ctx.globalAlpha = 1.0;
            }
        }
    }

    // High performance animation timer (~30 FPS)
    Timer {
        id: animTimer
        interval: 33
        running: true
        repeat: true
        onTriggered: {
            if (!canvas.initialized) return;

            const dt = 0.033;
            const pulses = canvas.pulses;
            const numTracks = canvas.tracks.length;
            if (numTracks === 0) return;

            for (let i = 0; i < pulses.length; i++) {
                const pulse = pulses[i];
                if (pulse.delay > 0) {
                    pulse.delay -= dt;
                    continue;
                }

                pulse.progress += pulse.speed * dt;

                // Re-arm pulse when it completes its run
                if (pulse.progress > 1.0) {
                    pulse.progress = 0.0;
                    pulse.trackIdx = Math.floor(Math.random() * numTracks);
                    pulse.direction = Math.random() > 0.5 ? 1 : -1;
                    pulse.speed = 0.14 + Math.random() * 0.32;
                    pulse.tailLen = 45 + Math.random() * 60;
                    pulse.color = root.signalPalette[Math.floor(Math.random() * root.signalPalette.length)];
                    pulse.delay = Math.random() * 1.5; // Stagger next burst
                }
            }
            canvas.requestPaint();
        }
    }
}
