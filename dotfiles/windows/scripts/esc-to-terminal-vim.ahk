#NoTrayIcon
#NoEnv

; Define variables for holding key press duration
CapsLock_Pressed := false
CapsLock_StartTime := 0

; Define the hotkey
#IfWinActive ahk_class CASCADIA_HOSTING_WINDOW_CLASS ; This is the class name for Windows Terminal

; When Caps Lock is pressed
CapsLock::
    CapsLock_Pressed := true
    CapsLock_StartTime := A_TickCount
    SetTimer, CheckCapsLock, 10
return

; When Caps Lock is released
CapsLock Up::
    CapsLock_Pressed := false
    SetTimer, CheckCapsLock, Off
    ; If the key was held for less than 120 milliseconds, send {Esc}
    if (A_TickCount - CapsLock_StartTime < 120)
    {
        Send {Esc}
    }
    else
    {
        Send {Ctrl Up}
    }
return

CheckCapsLock:
    ; If the key is still pressed and held for more than 120 milliseconds, send {Ctrl Down}
    if (CapsLock_Pressed and (A_TickCount - CapsLock_StartTime >= 120))
    {
        Send {Ctrl Down}
        SetTimer, CheckCapsLock, Off
    }
return

#IfWinActive

