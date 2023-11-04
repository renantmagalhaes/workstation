#MaxHotkeysPerInterval 10000
#NoTrayIcon
CoordMode, Mouse, Screen ; Coordinates will be relative to the screen

return ; End of auto-execute section

WheelUp::
    MouseGetPos, _, mouseY
    ScreenHeight := A_ScreenHeight
    if (mouseY <= 10 or mouseY >= ScreenHeight - 10) ; If the mouse is within 10 pixels of the top or within 10 pixels of the bottom
    {
        Send, ^#{Left} ; Send Ctrl+Win+Left
        Sleep, 30 ; Wait for 30 ms
    }
    else
    {
        Send {WheelUp} ; Otherwise, perform the normal wheel up action
    }
    return

WheelDown::
    MouseGetPos, _, mouseY
    ScreenHeight := A_ScreenHeight
    if (mouseY <= 10 or mouseY >= ScreenHeight - 10) ; If the mouse is within 10 pixels of the top or within 10 pixels of the bottom
    {
        Send, ^#{Right} ; Send Ctrl+Win+Right
        Sleep, 30 ; Wait for 30 ms
    }
    else
    {
        Send {WheelDown} ; Otherwise, perform the normal wheel down action
    }
    return
