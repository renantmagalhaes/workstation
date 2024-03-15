#NoTrayIcon

; ################## Send Current windows to next/previous monitor ################## ;
#Enter::
  Send {LWin down}{LShift down}{Left}{LShift up}{LWin up}
return

; In this case its necessary to define a custom combination by using "&" or "<#" 
; to avoid that LWin loses its original function as a modifier key:

<#d:: Send #d  ; <# means LWin