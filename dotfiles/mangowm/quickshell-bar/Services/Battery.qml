pragma Singleton

import Quickshell
import Quickshell.Services.UPower

// Peripheral batteries. This machine is a desktop with no system battery, so
// anything reported here is a mouse, keyboard or headset -- which is what the
// old waybar battery modules and battery-watchdog.sh were really tracking.
// The chip stays hidden until a device actually reports.
Singleton {
    id: root

    readonly property var peripheralTypes: [UPowerDeviceType.Mouse, UPowerDeviceType.Keyboard, UPowerDeviceType.Headset, UPowerDeviceType.Headphones, UPowerDeviceType.BluetoothGeneric, UPowerDeviceType.Speakers, UPowerDeviceType.GamingInput]

    readonly property var devices: {
        const all = UPower.devices?.values ?? [];
        return all.filter(d => d?.ready && root.peripheralTypes.includes(d.type) && d.percentage > 0);
    }

    readonly property bool hasAny: devices.length > 0
    readonly property var primary: devices[0] ?? null

    // UPower reports percentage as a 0-1 ratio; tolerate a device that hands
    // back 0-100 directly rather than showing "6300%".
    function toPercent(value) {
        if (value === undefined || value === null) return 0;
        return Math.round(value <= 1 ? value * 100 : value);
    }

    readonly property int percent: toPercent(primary?.percentage)
    readonly property bool low: hasAny && percent < 30

    readonly property string deviceName: {
        if (!primary) return "";
        if (primary.model) return primary.model;
        return UPowerDeviceType.toString(primary.type);
    }

    readonly property string icon: {
        if (!hasAny) return "󰂑";
        if (percent >= 90) return "󰁹";
        if (percent >= 70) return "󰂂";
        if (percent >= 50) return "󰁿";
        if (percent >= 30) return "󰁼";
        if (percent >= 15) return "󰁺";
        return "󰂎";
    }
}
