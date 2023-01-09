# Windows

Theme > Dark Bloon
Taskbar > Disable Show my taskbar on all displays

# Power Toys
## Keyboard Manager



# Windows SO

## Personalization

1. Personalization
   1. Colors -> Turf Green
   2. Transparency effects -> ON
   3. Show accent colour on title bars and windows borders -> ON

## PowerToys

### Run

- Activation key -> Alt + Space
- Number of results shown before scrolling -> 5
- Window Walker
  -  Score modifier -> 1000

[Copy scripts from this folder](./scripts/) to `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` or `shell:startup`
### Quick Accent

- Enable IT!!

### Keyboard Manager

![picture 1](../../images/2efa1624b4ff78e73b4e91b910d35c03944a722c2f2adbd43b6707a482a3d394.png)  


Plus all scripts from [this folder](./scripts/) to `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` or `shell:startup`
# Windows Terminal

## Startup

- Create a shortcut and send to `shell:startup` with Minimized option selected

![picture 1](../../images/a44c9c526cc6f73d3998c7697b807de8bebc3a3a8f6cf8ec97a6e38a400f6f1e.png)  


Default profile -> Ubuntu
Default Terminal application -> Windows Terminal

### Interaction

[Copy this JSON to terminal](./config/wsl-terminal/settings.json) or follow:

Enable Automatically copy selection to clipboard

- Appearance

Theme -> Dark

## Actions

1. + Add New
2. Summon Quake window
3. Set ctrl+enter
## **Profiles**

### Azure

General -> Hide profile from dropdown (enable)

### Ubuntu

General

Starting directory

```
\\wsl.localhost\Ubuntu\home\rtm
```

Appearance

Color scheme > One Half Dark
Font Face > FuraCode Nerd Font Retina

Enable Acrylic
Opacity -> 90%

Advanced

Disable all Bell notification

# Start11

## Start Menu

- Windows 11 Style

## Taskbar

Taskbarsize > Small

## Control

Set all to Windows Menu

# Stream Deck

- CPU
- Battery
- Weather
- Win Tools
- Speed Test
- OBS Tools
- IFTTT
- Visual Studio Code
- HWiNFO64
  - [Config file to import](./config/hwinfo/HWiNFO64_settings.reg)