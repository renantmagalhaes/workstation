#NoTrayIcon
#IfWinActive ahk_exe msedge.exe

; Right mouse button is held down and scroll wheel is moved down
~RButton & WheelDown::
    Send ^{Tab}
    Return

; Right mouse button is held down and scroll wheel is moved up
~RButton & WheelUp::
    Send ^+{Tab}
    Return

