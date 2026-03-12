#NoTrayIcon
; Tab bar color (hex from inspector Ctrl+Alt+C). Double-click on this color = new tab.
TabBarColor := "0x20201F"

; --- Inspector: Ctrl+Alt+C shows pixel color at cursor (Chrome active) ---
#IfWinActive ahk_exe chrome.exe
^!c::
    MouseGetPos, MouseX, MouseY
    PixelGetColor, color, %MouseX%, %MouseY%
    ; AHK returns BGR hex; extract RR GG BB for display
    r := "0x" . SubStr(color, 3, 2)
    g := "0x" . SubStr(color, 5, 2)
    b := "0x" . SubStr(color, 7, 2)
    r := r + 0
    g := g + 0
    b := b + 0
    tip := "Hex: " . color . " (use this in script)`nR:" . r . " G:" . g . " B:" . b
    ToolTip, %tip%, MouseX + 15, MouseY + 15
    SetTimer, RemoveToolTip, 3000
return
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return
#IfWinActive

; --- Double-click on tab bar (by color) = new tab ---
#IfWinActive ahk_exe chrome.exe
LButton::
    if (A_PriorHotkey = "LButton" and A_TimeSincePriorHotkey < 400) {
        MouseGetPos, MouseX, MouseY
        PixelGetColor, color, %MouseX%, %MouseY%
        if (color = TabBarColor) {
            SendEvent ^t
            return
        }
    }
    SendEvent {LButton down}
    KeyWait LButton
    SendEvent {LButton up}
return
#IfWinActive
