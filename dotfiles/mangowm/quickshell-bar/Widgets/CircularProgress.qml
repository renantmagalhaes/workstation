import QtQuick
import QtQuick.Shapes
import "../Config"

Item {
    id: root

    property real value: 0          // 0.0 to 1.0
    property int strokeWidth: 4
    property color fgColor: Theme.accent
    property color bgColor: Theme.wsEmpty
    property int startAngle: -90
    property int sweepAngle: 360

    readonly property real size: Math.min(width, height)
    readonly property real radius: Math.max(1, (size - strokeWidth) / 2)
    readonly property real clampedVal: Math.max(0.001, Math.min(1.0, isNaN(value) ? 0 : value))

    implicitWidth: 42
    implicitHeight: 42

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: true

        // Background circle track
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.bgColor
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.radius
                radiusY: root.radius
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Active value arc
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.fgColor
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.radius
                radiusY: root.radius
                startAngle: root.startAngle
                sweepAngle: root.clampedVal * root.sweepAngle
            }

            Behavior on strokeColor {
                ColorAnimation { duration: Theme.durSnappy }
            }
        }
    }
}
