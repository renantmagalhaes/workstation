#NoTrayIcon
#IfWinActive ahk_exe msedge.exe
#Persistent
SetTimer, CheckColor, 10
return

CheckColor:
    MouseGetPos, MouseX, MouseY
    PixelGetColor, color, %MouseX%, %MouseY%, RGB
    if (color = "0x2d2d2d") {
        Hotkey, WheelUp, ScrollUp, On
        Hotkey, WheelDown, ScrollDown, On
    } else {
        Hotkey, WheelUp, ScrollUp, Off
        Hotkey, WheelDown, ScrollDown, Off
    }
return

ScrollUp:
    Send ^+{Tab}
return

ScrollDown:
    Send ^{Tab}
return
#IfWinActive

