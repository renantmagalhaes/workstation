import QtQuick
import QtQuick.Shapes

// A squircle: a rectangle whose corners are superellipse quadrants rather than
// circular arcs, giving the continuous-curvature corner Apple uses. Qt has no
// native squircle (Rectangle only does circular `radius`), so the outline is
// generated as a polyline and filled by QtQuick.Shapes.
//
// `exponent` controls the corner: 2 is exactly a circular round-rect, higher
// values push the curve outward toward the corner, reading as "between a square
// and a rounded corner". 4 is the usual squircle.
//
// Optionally grows a speech-bubble tail out of the top edge, so a detached
// panel can point back at the thing that opened it. When `tailHeight > 0` the
// body starts at y = tailHeight and the tail occupies the strip above it.
Item {
    id: root

    property color fillColor: "black"
    property color borderColor: "transparent"
    property real borderWidth: 0
    property real radius: 16
    property real exponent: 4
    // Points per corner. 16 is indistinguishable from a curve at bar sizes.
    property int segments: 16

    property real tailHeight: 0
    property real tailWidth: 18
    property real tailX: width / 2

    readonly property var outline: buildOutline()

    function buildOutline() {
        const w = width;
        const h = height;
        const top = Math.max(0, tailHeight);
        const bodyHeight = h - top;
        if (w <= 0 || bodyHeight <= 0) return [];

        const r = Math.max(0, Math.min(radius, Math.min(w, bodyHeight) / 2));
        const n = Math.max(2, exponent);
        const segs = Math.max(4, segments);
        const points = [];

        // One superellipse quadrant. (cx, cy) is the centre of curvature and
        // (sx, sy) points from it toward the corner; the curve runs between the
        // two edge tangent points, bulging toward that corner.
        function quadrant(cx, cy, sx, sy, reverse) {
            for (let i = 0; i <= segs; i++) {
                const step = reverse ? segs - i : i;
                const t = (step / segs) * (Math.PI / 2);
                const x = r * Math.pow(Math.cos(t), 2 / n);
                const y = r * Math.pow(Math.sin(t), 2 / n);
                points.push(Qt.point(cx + sx * x, cy + sy * y));
            }
        }

        // Clockwise from the left edge. Straight sections are implied by the
        // polyline joining consecutive quadrant endpoints.
        quadrant(r, top + r, -1, -1, false);          // top-left

        if (top > 0 && tailWidth > 0) {
            const half = tailWidth / 2;
            // Keep the tail clear of the corners even if the anchor sits at the
            // very edge of the panel.
            const cx = Math.max(r + half, Math.min(w - r - half, tailX));
            const steps = 12;
            for (let i = 0; i <= steps; i++) {
                const t = i / steps;
                // Quadratic with the control point mirrored above the edge, so
                // x advances linearly while y traces top*(1-2t)^2 -- a smooth
                // tail whose tip just touches y = 0.
                points.push(Qt.point(cx - half + tailWidth * t, top * Math.pow(1 - 2 * t, 2)));
            }
        }

        quadrant(w - r, top + r, 1, -1, true);        // top-right
        quadrant(w - r, h - r, 1, 1, false);          // bottom-right
        quadrant(r, h - r, -1, 1, true);              // bottom-left

        // Close the outline so the stroke joins cleanly.
        points.push(points[0]);
        return points;
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: false

        ShapePath {
            fillColor: root.fillColor
            strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
            strokeWidth: root.borderWidth
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: root.outline
            }
        }
    }
}
