;#NoTrayIcon;

;-----------------------------------------;
; Winkey PowerToys Run                    ;
;-----------------------------------------;

; Variables
replaceStartMenu := true

; Use replacement Start Menu, or activate Start Menu
LWin Up::
    if (replaceStartMenu)
        if (A_PriorKey = "LWin") ; A_PriorKey is the key that was last pressed
            send {LAlt Down}{Space Down}{LAlt Up}{Space Up}
        else
        return
    else
        send {LWin}
    return
return

; Toggle Start Menu Replacement, also allows Win Key Hotkeys to work
RControl & Pause::
    If replaceStartMenu
        replaceStartMenu := false
    else
        replaceStartMenu := true
    return
return