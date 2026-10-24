pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    anchors.fill: parent

    // Configuration
    property color starColor: Qt.rgba(0.9, 0.95, 1.0, 0.7)
    property color cometCoreColor: "#FFFFFF"
    property color cometTailColor: "#78FFB4"      // Celestial Mint
    property color cometTailAltColor: "#00E5FF"   // Cyan Ion Trail
    property color cometWarmColor: "#FFE082"      // Starlight Gold

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property var stars: []
        property var meteors: []
        property var particles: []
        property bool initialized: false

        function initSky() {
            const w = width;
            const h = height;
            if (w <= 100 || h <= 100) return;

            // 1. Generate multi-depth starfield (Distant and midground stars)
            const starCount = 85;
            const newStars = [];
            for (let i = 0; i < starCount; i++) {
                newStars.push({
                    x: Math.random() * w,
                    y: Math.random() * h,
                    radius: 0.6 + Math.random() * 1.4,
                    baseAlpha: 0.15 + Math.random() * 0.55,
                    twinkleSpeed: 0.8 + Math.random() * 2.2,
                    phase: Math.random() * Math.PI * 2
                });
            }
            stars = newStars;

            // 2. Pre-allocate active meteors / shooting stars
            const meteorCount = 7;
            const newMeteors = [];
            for (let m = 0; m < meteorCount; m++) {
                newMeteors.push(createMeteor(w, h, true));
            }
            meteors = newMeteors;
            particles = [];
            initialized = true;
        }

        function createMeteor(w, h, initialDelay) {
            // Radiant angle: Meteors streak downwards from top-right to bottom-left (~35 degrees from horizontal)
            const baseAngle = (145 + (Math.random() * 16 - 8)) * (Math.PI / 180);
            const speed = 450 + Math.random() * 650; // pixels per second
            const isGrandComet = Math.random() < 0.22; // 22% chance to be a large glowing comet

            // Choose palette
            let tailCol = root.cometTailColor;
            const r = Math.random();
            if (r < 0.45) tailCol = root.cometTailColor;      // Mint #78FFB4
            else if (r < 0.80) tailCol = root.cometTailAltColor; // Cyan #00E5FF
            else tailCol = root.cometWarmColor;                 // Gold #FFE082

            return {
                x: Math.random() * (w * 1.3) - w * 0.1,
                y: -Math.random() * (h * 0.4) - 40,
                vx: Math.cos(baseAngle) * speed,
                vy: Math.sin(baseAngle) * speed,
                length: isGrandComet ? (180 + Math.random() * 140) : (70 + Math.random() * 80),
                width: isGrandComet ? (2.8 + Math.random() * 1.6) : (1.2 + Math.random() * 0.8),
                isGrand: isGrandComet,
                tailColor: tailCol,
                life: 0.0,
                maxLife: 1.4 + Math.random() * 1.2,
                active: false,
                delay: initialDelay ? (Math.random() * 6.0) : (0.4 + Math.random() * 3.5)
            };
        }

        onWidthChanged: { initSky(); requestPaint(); }
        onHeightChanged: { initSky(); requestPaint(); }

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;

            ctx.clearRect(0, 0, w, h);
            if (!initialized) return;

            const now = Date.now() * 0.001;

            // 1. Draw twinkling starfield
            for (let i = 0; i < stars.length; i++) {
                const s = stars[i];
                const alpha = s.baseAlpha + Math.sin(now * s.twinkleSpeed + s.phase) * (s.baseAlpha * 0.55);
                ctx.beginPath();
                ctx.arc(s.x, s.y, s.radius, 0, Math.PI * 2);
                ctx.fillStyle = Qt.rgba(0.9, 0.95, 1.0, Math.max(0.08, alpha));
                ctx.fill();
            }

            // 2. Draw stardust particle embers from comets
            for (let i = particles.length - 1; i >= 0; i--) {
                const p = particles[i];
                if (p.life <= 0) {
                    particles.splice(i, 1);
                    continue;
                }

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.radius * (p.life / p.maxLife), 0, Math.PI * 2);
                ctx.fillStyle = p.color;
                ctx.globalAlpha = (p.life / p.maxLife) * 0.7;
                ctx.fill();
            }
            ctx.globalAlpha = 1.0;

            // 3. Draw active meteors and comets
            for (let m = 0; m < meteors.length; m++) {
                const meteor = meteors[m];
                if (!meteor.active) continue;

                const normLife = meteor.life / meteor.maxLife;
                const fade = Math.sin(normLife * Math.PI); // Fade in and fade out smoothly

                // Tail vector
                const angle = Math.atan2(meteor.vy, meteor.vx);
                const tailX = meteor.x - Math.cos(angle) * meteor.length;
                const tailY = meteor.y - Math.sin(angle) * meteor.length;

                // Gradient tail
                const grad = ctx.createLinearGradient(tailX, tailY, meteor.x, meteor.y);
                grad.addColorStop(0.0, "rgba(0, 0, 0, 0)");
                grad.addColorStop(0.65, meteor.tailColor);
                grad.addColorStop(1.0, "#FFFFFF");

                ctx.beginPath();
                ctx.moveTo(tailX, tailY);
                ctx.lineTo(meteor.x, meteor.y);
                ctx.strokeStyle = grad;
                ctx.lineWidth = meteor.width;
                ctx.lineCap = "round";
                ctx.globalAlpha = fade * 0.85;
                ctx.stroke();

                // Bright comet head / nucleus
                ctx.beginPath();
                ctx.arc(meteor.x, meteor.y, meteor.width + 1.2, 0, Math.PI * 2);
                ctx.fillStyle = "#FFFFFF";
                ctx.globalAlpha = fade * 0.95;
                ctx.fill();

                // Outer radiant halo for grand comets
                if (meteor.isGrand) {
                    ctx.beginPath();
                    ctx.arc(meteor.x, meteor.y, meteor.width + 5.5, 0, Math.PI * 2);
                    ctx.fillStyle = meteor.tailColor;
                    ctx.globalAlpha = fade * 0.35;
                    ctx.fill();
                }

                ctx.globalAlpha = 1.0;
            }
        }
    }

    // Physics and animation simulation timer (~30 FPS)
    Timer {
        id: animTimer
        interval: 33
        running: true
        repeat: true
        onTriggered: {
            if (!canvas.initialized) return;

            const dt = 0.033;
            const w = canvas.width;
            const h = canvas.height;
            const meteors = canvas.meteors;
            const particles = canvas.particles;

            // Update meteors
            for (let m = 0; m < meteors.length; m++) {
                const meteor = meteors[m];

                if (meteor.delay > 0) {
                    meteor.delay -= dt;
                    if (meteor.delay <= 0) {
                        meteor.active = true;
                    }
                    continue;
                }

                if (!meteor.active) continue;

                meteor.x += meteor.vx * dt;
                meteor.y += meteor.vy * dt;
                meteor.life += dt;

                // Grand comets drop stardust embers
                if (meteor.isGrand && Math.random() < 0.55 && particles.length < 50) {
                    particles.push({
                        x: meteor.x + (Math.random() * 4 - 2),
                        y: meteor.y + (Math.random() * 4 - 2),
                        radius: 1.2 + Math.random() * 1.5,
                        color: meteor.tailColor,
                        life: 0.6 + Math.random() * 0.5,
                        maxLife: 0.6 + Math.random() * 0.5
                    });
                }

                // Despawn if out of bounds or life expired
                if (meteor.life >= meteor.maxLife || meteor.x < -200 || meteor.y > h + 200) {
                    meteors[m] = canvas.createMeteor(w, h, false);
                }
            }

            // Update particle embers
            for (let i = 0; i < particles.length; i++) {
                particles[i].life -= dt;
            }

            canvas.requestPaint();
        }
    }
}
