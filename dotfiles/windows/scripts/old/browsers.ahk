#NoTrayIcon

; ################## Edge Browser ################## ;

#IfWinActive ahk_exe msedge.exe
F2::
  Send {LCtrl down}{LShift down}{a}{LShift up}{LCtrl up}
return


#IfWinActive ahk_exe msedge.exe
^Space::
  Send {LCtrl down}{LShift down}{o}{LShift up}{LCtrl up}
return

; ################## Chrome Browser ################## ;

#IfWinActive ahk_exe chrome.exe
F2::
  Send {LCtrl down}{LShift down}{a}{LShift up}{LCtrl up}
return


#IfWinActive ahk_exe chrome.exe
^Space::
  Send {LCtrl down}{LShift down}{o}{LShift up}{LCtrl up}
return

; In this case its necessary to define a custom combination by using "&" or "<#" 
; to avoid that LWin loses its original function as a modifier key:

<#d:: Send #d  ; <# means LWin