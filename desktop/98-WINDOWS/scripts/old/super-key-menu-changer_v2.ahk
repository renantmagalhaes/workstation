#NoTrayIcon

LWin up::
If (A_PriorKey = "LWin")
    send {LAlt Down}{Space Down}{LAlt Up}{Space Up}
return

; In this case its necessary to define a custom combination by using "&" or "<#" 
; to avoid that LWin loses its original function as a modifier key:

<#d:: Send #d  ; <# means LWin