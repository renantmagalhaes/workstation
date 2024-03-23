#MaxHotkeysPerInterval 10000
#NoTrayIcon
CoordMode, Mouse, Screen ; Coordinates will be relative to the screen

return ; End of auto-execute section

WheelUp::
    MouseGetPos, mouseX, mouseY
    SysGet, MonitorCount, MonitorCount ; Gets the number of monitors
    Loop, %MonitorCount% { ; Loop through each monitor
        SysGet, Monitor, Monitor, %A_Index% ; Get monitor details
        ; Check if the mouse is within the bounds of the current monitor
        if (mouseX >= MonitorLeft and mouseX <= MonitorRight and mouseY >= MonitorTop and mouseY <= MonitorBottom) {
            if (mouseY <= MonitorTop + 10 or mouseY >= MonitorBottom - 10) { ; Check if the mouse is near the top or bottom edge
                Send, ^#{Left} ; Send Ctrl+Win+Left
                Sleep, 30 ; Wait for 30 ms
                return
            }
        }
    }
    Send {WheelUp} ; Otherwise, perform the normal wheel up action
    return

WheelDown::
    MouseGetPos, mouseX, mouseY
    SysGet, MonitorCount, MonitorCount ; Gets the number of monitors
    Loop, %MonitorCount% { ; Loop through each monitor
        SysGet, Monitor, Monitor, %A_Index% ; Get monitor details
        ; Check if the mouse is within the bounds of the current monitor
        if (mouseX >= MonitorLeft and mouseX <= MonitorRight and mouseY >= MonitorTop and mouseY <= MonitorBottom) {
            if (mouseY <= MonitorTop + 10 or mouseY >= MonitorBottom - 10) { ; Check if the mouse is near the top or bottom edge
                Send, ^#{Right} ; Send Ctrl+Win+Right
                Sleep, 30 ; Wait for 30 ms
                return
            }
        }
    }
    Send {WheelDown} ; Otherwise, perform the normal wheel down action
    return
