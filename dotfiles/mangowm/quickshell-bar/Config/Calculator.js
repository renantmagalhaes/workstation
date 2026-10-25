.pragma library

// Robust and safe math calculator for QuickShell launcher
// Supports:
// - Basic arithmetic (+, -, *, /, %, ^, **)
// - Percentage expressions: "15% of 80", "15% * 80", "200 + 10%", "500 - 20%"
// - Math functions: sqrt, cbrt, sin, cos, tan, asin, acos, atan, sinh, cosh, tanh,
//                   log, log10, log2, exp, abs, floor, ceil, round, pow, min, max
// - Constants: pi, e
// - Clean formatting with comma separators for readability

function calculate(query) {
    if (!query) return null;
    let text = query.trim();
    if (text.length < 2) return null;

    const hasCalcPrefix = text.startsWith("=") || text.toLowerCase().startsWith("calc ");
    if (text.startsWith("=")) {
        text = text.slice(1).trim();
    } else if (text.toLowerCase().startsWith("calc ")) {
        text = text.slice(5).trim();
    }
    if (!text) return null;

    // 1. Percentage check: "X% of Y" or "X% * Y"
    let m = text.match(/^([\d.]+)\s*%\s*(?:of|\*)\s*([\d.]+)$/i);
    if (m) {
        const p = parseFloat(m[1]);
        const total = parseFloat(m[2]);
        if (!isNaN(p) && !isNaN(total)) {
            const res = (p / 100) * total;
            return {
                expression: text,
                result: formatNumber(res),
                raw: res
            };
        }
    }

    // 2. Percentage addition/subtraction: "X + Y%" or "X - Y%"
    m = text.match(/^([\d.]+)\s*([+-])\s*([\d.]+)\s*%$/);
    if (m) {
        const base = parseFloat(m[1]);
        const op = m[2];
        const pct = parseFloat(m[3]);
        if (!isNaN(base) && !isNaN(pct)) {
            const diff = base * (pct / 100);
            const res = op === "+" ? base + diff : base - diff;
            return {
                expression: text,
                result: formatNumber(res),
                raw: res
            };
        }
    }

    // 3. Normalize arithmetic string
    // Replace comma with dot if between digits (e.g. 12,5 -> 12.5)
    let expr = text.replace(/(\d),(\d)/g, "$1.$2");
    // Replace ^ with ** (power)
    expr = expr.replace(/\^/g, "**");

    const mathFns = [
        "sqrt", "cbrt", "asin", "acos", "atan", "sinh", "cosh", "tanh",
        "sin", "cos", "tan", "log10", "log2", "log", "exp", "abs",
        "floor", "ceil", "round", "pow", "min", "max"
    ];

    // Must have at least one operator or math function if no explicit prefix
    const hasOperator = /[+\-*/%^]/.test(expr) || /\b(sqrt|sin|cos|tan|log|abs|pi|pow)\b/i.test(expr);
    const hasDigit = /\d/.test(expr);
    if (!hasCalcPrefix && (!hasOperator || !hasDigit)) {
        return null;
    }

    // Sanitize characters: strip allowed tokens first, then ensure remaining are only valid arithmetic characters
    let sanitized = expr;
    sanitized = sanitized.replace(/\bpi\b/gi, "");
    sanitized = sanitized.replace(/\be\b/gi, "");
    for (let i = 0; i < mathFns.length; i++) {
        sanitized = sanitized.replace(new RegExp("\\b" + mathFns[i] + "\\b", "gi"), "");
    }
    if (!/^[\d\s+*/%(),.**\-]+$/.test(sanitized)) {
        return null;
    }

    // Replace math tokens with Math.<token>
    let evalStr = expr;
    evalStr = evalStr.replace(/\bpi\b/gi, "Math.PI");
    evalStr = evalStr.replace(/\be\b/gi, "Math.E");
    for (let i = 0; i < mathFns.length; i++) {
        const fnName = mathFns[i];
        evalStr = evalStr.replace(new RegExp("\\b" + fnName + "\\b", "gi"), "Math." + fnName);
    }

    try {
        const fn = new Function('"use strict"; return (' + evalStr + ")");
        const val = fn();
        if (typeof val === "number" && isFinite(val)) {
            return {
                expression: text,
                result: formatNumber(val),
                raw: val
            };
        }
    } catch (e) {
        return null;
    }
    return null;
}

function formatNumber(num) {
    if (typeof num !== "number" || !isFinite(num)) return String(num);
    const rounded = Math.round(num * 1e10) / 1e10;
    const parts = String(rounded).split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}
