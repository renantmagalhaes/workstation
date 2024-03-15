;Line 4 makes LWin a prefix key, which means that other existing bindings will still work as expected
;You will have to check "Use centralized keyboard hook" in the Powertoys Run configuration. 
;You can then start the script and change the activation shortcut. 
;I am using Ctrl+Shift+Alt+F24 because that's very unlikely to interfere with any other shortcuts.
#NoEnv
SendMode Input

~LWin & F1::return  ; Make LWin a prefix key (https://www.autohotkey.com/docs/v2/Hotkeys.htm#prefix)
LWin::^!+F24

