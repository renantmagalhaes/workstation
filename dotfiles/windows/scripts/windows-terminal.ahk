#NoTrayIcon

^Enter::
    Process, Exist, WindowsTerminal.exe
    if (ErrorLevel = 0) {
        ; Windows Terminal is not running, launch it
        Run, wt.exe
    } else {
        ; Windows Terminal is running, let Windows handle the shortcut
        Send, {Blind}^{Enter}  ; Sends Ctrl+Enter without retriggering the script
    }
return
