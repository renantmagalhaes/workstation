#NoTrayIcon
#NoEnv

; Define the hotkey
#IfWinActive ahk_class CASCADIA_HOSTING_WINDOW_CLASS ; This is the class name for Windows Terminal
CapsLock::Send {Esc}
#IfWinActive