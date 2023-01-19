;#NoTrayIcon;

;-----------------------------------------;
; Winkey PowerToys Run                    ;
;-----------------------------------------;

; Use PowerToysRun as replacement for Start Menu
LWin Up::
    Process, Exist, PowerToys.PowerLauncher.exe
    if (ErrorLevel == 0) ; PTRun not running
        send {LWin}
    else ; PTRun is running
        if (A_PriorKey = "LWin") ; A_PriorKey is the key that was last pressed
            send {LAlt Down}{Space Down}{LAlt Up}{Space Up}
return

; Important: Allows Win Key Hotkeys to work
LAlt & Space::
return