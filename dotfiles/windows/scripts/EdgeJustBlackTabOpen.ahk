#NoTrayIcon
#IfWinActive ahk_exe msedge.exe
~LButton::
    if (A_PriorHotkey = "~LButton" and A_TimeSincePriorHotkey < 400) {
        MouseGetPos, MouseX, MouseY
        PixelGetColor, color, %MouseX%, %MouseY%
        if (color = "0x2d2d2d") {
            SendEvent ^t
        }
    }
return
#IfWinActive

