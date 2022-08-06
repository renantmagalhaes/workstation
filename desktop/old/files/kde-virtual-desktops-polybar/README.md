# original github
https://github.com/KevinThomas0/kde-virtual-desktops-polybar

#kde-virtual-desktops-polybar
kde-virtual-desktops-polybar is a collection of scripts meant to be used
in modules for Polybar.

`kde-virtual-desktops` will automatically detect your KWin virtual desktops
and highlight your active one, either by name or number. `kde-next-desktop`
and `kde-previous-desktop` will switch your active desktop to the next or
previous one.

## Example Polybar Configuration

Display virtual desktops with active desktop highlighted, scroll over the
module to switch to previous and next desktops:
```ini
[module/kde-virtual-desktops]
type = custom/script
exec = ~/.config/polybar/scripts/kde-virtual-desktops
scroll-up = ~/.config/polybar/scripts/kde-previous-desktop
scroll-down = ~/.config/polybar/scripts/kde-next-desktop
tail = true
label = %output%
```

## Configuration
`kde-virtual-desktops` configuration is done inside the script:
```bash
### Configuration
accentColor="#ff79c6" # text color of active desktop
separator="|"         # separator string in between desktop names or numbers
useDesktopNames=false # set to true to use desktop names instead of numbers
###
```

