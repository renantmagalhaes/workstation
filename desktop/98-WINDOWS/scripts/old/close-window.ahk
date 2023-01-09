#NoTrayIcon

#q:: ; Windows+q triggers the following
Send !{f4} ; Simulates the keypress alt+f4
return ; Finished

; In this case its necessary to define a custom combination by using "&" or "<#" 
; to avoid that LWin loses its original function as a modifier key:

<#d:: Send #d  ; <# means LWin