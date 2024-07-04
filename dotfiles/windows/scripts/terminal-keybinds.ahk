#NoTrayIcon
#NoEnv

; Define the hotkey
#IfWinActive ahk_class CASCADIA_HOSTING_WINDOW_CLASS ; This is the class name for Windows Terminal
; Remap CapsLock to ESC
CapsLock::Send {Esc}

; Remap CapsLock + A to Ctrl + B
CapsLock & a::
    Send ^b
return

#IfWinActive

