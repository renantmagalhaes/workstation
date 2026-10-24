import QtQuick
import "../Config"

// Live rolling sparkline graph (Canvas) for network throughput.
Canvas {
    id: root

    property var rxHistory: []
    property var txHistory: []

    property color rxColor: Theme.accent
    property color txColor: Theme.good

    antialiasing: true

    onRxHistoryChanged: requestPaint()
    onTxHistoryChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const w = width;
        const h = height;

        ctx.clearRect(0, 0, w, h);
        if (w <= 0 || h <= 0) return;

        // Faint horizontal baseline & midpoint gridline
        ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.07);
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(0, h * 0.5);
        ctx.lineTo(w, h * 0.5);
        ctx.moveTo(0, h - 2);
        ctx.lineTo(w, h - 2);
        ctx.stroke();

        // Find peak across data sets (minimum 10 KB/s floor so idle doesn't blow up)
        let peak = 1024 * 10;
        if (rxHistory && rxHistory.length > 0) {
            for (let i = 0; i < rxHistory.length; i++) {
                if (rxHistory[i] > peak) peak = rxHistory[i];
            }
        }
        if (txHistory && txHistory.length > 0) {
            for (let i = 0; i < txHistory.length; i++) {
                if (txHistory[i] > peak) peak = txHistory[i];
            }
        }

        function drawSeries(data, strokeCol, fillAlpha) {
            if (!data || data.length < 2) return;
            const count = data.length;
            const step = w / (count - 1);

            // Fill area under curve
            ctx.beginPath();
            ctx.moveTo(0, h - 2);
            for (let i = 0; i < count; i++) {
                const x = i * step;
                const ratio = Math.max(0, Math.min(1.0, data[i] / peak));
                const y = (h - 2) - (ratio * (h - 8));
                ctx.lineTo(x, y);
            }
            ctx.lineTo(w, h - 2);
            ctx.closePath();
            ctx.fillStyle = Qt.alpha(strokeCol, fillAlpha);
            ctx.fill();

            // Stroke line along the curve
            ctx.beginPath();
            for (let i = 0; i < count; i++) {
                const x = i * step;
                const ratio = Math.max(0, Math.min(1.0, data[i] / peak));
                const y = (h - 2) - (ratio * (h - 8));
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.strokeStyle = strokeCol;
            ctx.lineWidth = 1.5;
            ctx.stroke();
        }

        // Draw TX (upload) first, then RX (download) on top
        drawSeries(txHistory, txColor, 0.18);
        drawSeries(rxHistory, rxColor, 0.30);
    }
}
