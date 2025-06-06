#SingleInstance Force  ; Only run once

Sleep, 500  ; Give the system a few seconds after login

totalDesktops := 5  ; <<-- Set your total number of workspaces here

Loop, % (totalDesktops - 1)
{
    Send, ^#{Left}
    Sleep, 100
}

ExitApp