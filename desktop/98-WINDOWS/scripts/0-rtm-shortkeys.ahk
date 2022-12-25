;#NoTrayIcon;

; ################## Close Window ################## ;
#q:: ; Windows+q triggers the following
Send !{f4} ; Simulates the keypress alt+f4
return ; Finished



; ################## PowerToys Run with Win Key ################## ;
LWin up::
If (A_PriorKey = "LWin")
    send {LAlt Down}{Space Down}{LAlt Up}{Space Up}
return


; ################## Send Current windows to next/previous workspace ################## ;
^+#Left::
  WinGetTitle, Title, A
  WinSet, ExStyle, ^0x80, %Title%
  Send {LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}
  sleep, 50
  WinSet, ExStyle, ^0x80, %Title%
  WinActivate, %Title%
Return

^+#Right::
  WinGetTitle, Title, A
  WinSet, ExStyle, ^0x80, %Title%
  Send {LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}
  sleep, 50
  WinSet, ExStyle, ^0x80, %Title%
  WinActivate, %Title%
Return


; ################## Send Current windows to next/previous monitor ################## ;
#Enter::
  Send {LWin down}{LShift down}{Left}{LShift up}{LWin up}
return


; ################## EXTRA CONFIGS ################## ;
; In this case its necessary to define a custom combination by using "&" or "<#"
; to avoid that LWin loses its original function as a modifier key:
<#d:: Send #d  ; <# means LWin