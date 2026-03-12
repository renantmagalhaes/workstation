; Focus follows mouse (sloppy focus) — like tiling WMs.
; The window under the cursor is activated automatically; no click needed.
#NoTrayIcon
#Persistent

; === CONFIG ===
global PollInterval := 100
global HoverDelay := 80

global LastUnderId := 0
global HoverStart := 0

SetTimer, FocusFollowsMouse, %PollInterval%
return

FocusFollowsMouse:
  ; Don't change focus while a mouse button is held (e.g. right-click context menu)
  if (GetKeyState("RButton", "P") || GetKeyState("LButton", "P") || GetKeyState("MButton", "P"))
    return

  MouseGetPos, , , underId, underControl
  if (!underId)
    return

  ; Activate the top-level (root) window — child windows often don't take focus correctly
  rootId := DllCall("GetAncestor", "Ptr", underId, "UInt", 2, "Ptr")  ; GA_ROOT = 2
  if (rootId && rootId != underId)
    underId := rootId

  WinGetClass, underClass, ahk_id %underId%

  ; Skip desktop, taskbar
  if (underClass = "Progman" || underClass = "WorkerW")
    return
  if (underClass = "Shell_TrayWnd" || underClass = "Shell_SecondaryTrayWnd")
    return

  WinGet, style, Style, ahk_id %underId%
  if (style & 0x8000000)  ; WS_DISABLED
    return

  activeId := WinExist("A")
  if (underId = activeId)
  {
    LastUnderId := underId
    return
  }

  if (underId != LastUnderId)
  {
    HoverStart := A_TickCount
    LastUnderId := underId
  }

  if ((A_TickCount - HoverStart) >= HoverDelay)
  {
    WinActivate, ahk_id %underId%
    DllCall("SetForegroundWindow", "Ptr", underId)
    LastUnderId := underId
  }
return
