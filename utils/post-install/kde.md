# KDE

# Themes
Kvantum -> Orchis-dark
Global Theme -> Orchis-dark
Icons -> Tela Circle
Window Decorations -> Orchis-dark
Cursors -> Breeze Light
Splash Screen -> QuarksSplashDark


# System Settings

- Compositor
  - Rendering backend (OpenGL 3.1)
- Application Style
  - Configure GNOME/GTK
- Desktop effects
  - Enable Blur
  - Dim Screen for Administrator Mode
  - Slide Back
  - Enable Magic Lamp
    - Animation 170ms
  <!-- - Enable Wobby Windows -->
    <!-- - Uncheck Wobbly when resizing. -->
  - Desktop Grid
    - Layout mode: Pager
  - Disable Screen Edge (highlight)
- Task Switcher
  - Thumbnail Grid
- Virtual Desktops
  - Add 4 rows
  - Add 4 Desktops
  - Disable Navigation Wraps Around
- Screen Edges
  - Disable all
  - Top left corner
    - Present Windows (current desktop)
- Desktop Session
  - Start with an empty session
- General Behaviour (double click)
  - Clicking files or folders: 
    - Selects them
- Left Click on desktop -> Configure Desktop and Wallpaper
  - Wallpaper Type -> GetNEw Plugins -> Inactive Blur
    - Blur by 40% over 400ms
- Left Click on desktop -> Configure Desktop and Wallpaper
  - Wallpaper Type -> GetNEw Plugins -> Smart Video Wallpaper
    - https://mylivewallpapers.com
    - https://www.pexels.com/videos/
    - https://pixabay.com/videos/search/live%20wallpaper/


## KDE Taskbar

### Widgets

- Menu11
- Two spacers (and center task Manager)
- Virtual Desktop Bar(https://github.com/wsdfhjxc/virtual-desktop-bar)
- Dash to panel style indicator (latte-dock)
- Latte Separator

### Configs
- Alternative Show desktop to Minimize all Windows 
  - Keyboard shortcut into configurations (Meda+D)
- Center Taskmanager
- Center Menu11
- Systemtray
  - Disable Mediaplayer
  - Network (always show)


<!-- ### KDE top scroll bar
1. Add commond empty panel
2. Edit ~/.config/plasma-org.kde.plasma.desktop-appletsrc
   1. add under [ActionPlugins][1]
      1. wheel:Vertical;NoModifier=org.kde.switchdesktop
3. Keyboard and shortcut for menu -> Alt + F1
4. Disable notification system tray (top panel) -->
<!-- 5. Change ~/.config/plasmashellrc
   1. thickness=5 to thickness=3 -->

- Widgets
  - Windows Buttons / Windows Title / AppMenu
  
Configs

- Windows Buttons
  - Decoration WhiteSur
  - Active windows is maximized
  - Show only for windows in current screen
  - Nodic Window Decorations

- Windows Title
  - Behaviour
    - Show only windows information from current screen
    - Disable scroll to cycle and minimize through your tasks
    - Disable placeholder
  
- AppMenu
  - Menu Colors Orchis Dark
  - Filters ONLY: Show only menus from current screen


# KWin Scripts

Hide Titles
## Shortcuts

```
~/.config/kglobalshortcutsrc
```

```
Mute microphone
Dolphin
```

```
[org.flameshot.Flameshot.desktop]
Capture=Ctrl+Print,,Take screenshot
Configure=,,Configure
Launcher=,,Open launcher
_k_friendly_name=Flameshot
_launch=,,Flameshot

[kwin]
Activate Window Demanding Attention=Ctrl+Alt+A,Ctrl+Alt+A,Activate Window Demanding Attention
Decrease Opacity=none,none,Decrease Opacity of Active Window by 5 %
Expose=Meta+Tab,Ctrl+F9,Toggle Present Windows (Current desktop)
ExposeAll=Ctrl+F10\tLaunch (C),Ctrl+F10\tLaunch (C),Toggle Present Windows (All desktops)
ExposeClass=Ctrl+F7,Ctrl+F7,Toggle Present Windows (Window class)
Increase Opacity=none,none,Increase Opacity of Active Window by 5 %
Invert Screen Colors=none,none,Invert Screen Colors
Kill Window=Ctrl+Alt+Esc,Ctrl+Alt+Esc,Kill Window
MoveMouseToCenter=Meta+F6,Meta+F6,Move Mouse to Center
MoveMouseToFocus=Meta+F5,Meta+F5,Move Mouse to Focus
MoveZoomDown=none,none,Move Zoomed Area Downwards
MoveZoomLeft=none,none,Move Zoomed Area to Left
MoveZoomRight=none,none,Move Zoomed Area to Right
MoveZoomUp=none,none,Move Zoomed Area Upwards
Setup Window Shortcut=none,none,Setup Window Shortcut
Show Desktop=,Meta+D,Show Desktop
ShowDesktopGrid=Meta+Space,Ctrl+F8,Show Desktop Grid
Suspend Compositing=Alt+Shift+F12,Alt+Shift+F12,Suspend Compositing
Switch One Desktop Down=Ctrl+Alt+Down,Meta+Ctrl+Down,Switch One Desktop Down
Switch One Desktop Up=Ctrl+Alt+Up,Meta+Ctrl+Up,Switch One Desktop Up
Switch One Desktop to the Left=none,Meta+Ctrl+Left,Switch One Desktop to the Left
Switch One Desktop to the Right=none,Meta+Ctrl+Right,Switch One Desktop to the Right
Switch Window Down=Meta+Alt+Down,Meta+Alt+Down,Switch to Window Below
Switch Window Left=Meta+Alt+Left,Meta+Alt+Left,Switch to Window to the Left
Switch Window Right=Meta+Alt+Right,Meta+Alt+Right,Switch to Window to the Right
Switch Window Up=Meta+Alt+Up,Meta+Alt+Up,Switch to Window Above
Switch to Desktop 1=Ctrl+F1,Ctrl+F1,Switch to Desktop 1
Switch to Desktop 10=none,none,Switch to Desktop 10
Switch to Desktop 11=none,none,Switch to Desktop 11
Switch to Desktop 12=none,none,Switch to Desktop 12
Switch to Desktop 13=none,none,Switch to Desktop 13
Switch to Desktop 14=none,none,Switch to Desktop 14
Switch to Desktop 15=none,none,Switch to Desktop 15
Switch to Desktop 16=none,none,Switch to Desktop 16
Switch to Desktop 17=none,none,Switch to Desktop 17
Switch to Desktop 18=none,none,Switch to Desktop 18
Switch to Desktop 19=none,none,Switch to Desktop 19
Switch to Desktop 2=Ctrl+F2,Ctrl+F2,Switch to Desktop 2
Switch to Desktop 20=none,none,Switch to Desktop 20
Switch to Desktop 3=Ctrl+F3,Ctrl+F3,Switch to Desktop 3
Switch to Desktop 4=Ctrl+F4,Ctrl+F4,Switch to Desktop 4
Switch to Desktop 5=none,none,Switch to Desktop 5
Switch to Desktop 6=none,none,Switch to Desktop 6
Switch to Desktop 7=none,none,Switch to Desktop 7
Switch to Desktop 8=none,none,Switch to Desktop 8
Switch to Desktop 9=none,none,Switch to Desktop 9
Switch to Next Desktop=none,none,Switch to Next Desktop
Switch to Next Screen=,none,Switch to Next Screen
Switch to Previous Desktop=none,none,Switch to Previous Desktop
Switch to Previous Screen=none,none,Switch to Previous Screen
Switch to Screen 0=none,none,Switch to Screen 0
Switch to Screen 1=none,none,Switch to Screen 1
Switch to Screen 2=none,none,Switch to Screen 2
Switch to Screen 3=none,none,Switch to Screen 3
Switch to Screen 4=none,none,Switch to Screen 4
Switch to Screen 5=none,none,Switch to Screen 5
Switch to Screen 6=none,none,Switch to Screen 6
Switch to Screen 7=none,none,Switch to Screen 7
Toggle Night Color=none,none,Toggle Night Color
Toggle Window Raise/Lower=none,none,Toggle Window Raise/Lower
Walk Through Desktop List=none,none,Walk Through Desktop List
Walk Through Desktop List (Reverse)=none,none,Walk Through Desktop List (Reverse)
Walk Through Desktops=none,none,Walk Through Desktops
Walk Through Desktops (Reverse)=none,none,Walk Through Desktops (Reverse)
Walk Through Windows=Alt+Tab,Alt+Tab,Walk Through Windows
Walk Through Windows (Reverse)=Alt+Shift+Backtab,Alt+Shift+Backtab,Walk Through Windows (Reverse)
Walk Through Windows Alternative=none,none,Walk Through Windows Alternative
Walk Through Windows Alternative (Reverse)=none,none,Walk Through Windows Alternative (Reverse)
Walk Through Windows of Current Application=Alt+`,Alt+`,Walk Through Windows of Current Application
Walk Through Windows of Current Application (Reverse)=Alt+~,Alt+~,Walk Through Windows of Current Application (Reverse)
Walk Through Windows of Current Application Alternative=none,none,Walk Through Windows of Current Application Alternative
Walk Through Windows of Current Application Alternative (Reverse)=none,none,Walk Through Windows of Current Application Alternative (Reverse)
Window Above Other Windows=none,none,Keep Window Above Others
Window Below Other Windows=none,none,Keep Window Below Others
Window Close=Alt+F4,Alt+F4,Close Window
Window Fullscreen=none,none,Make Window Fullscreen
Window Grow Horizontal=none,none,Pack Grow Window Horizontally
Window Grow Vertical=none,none,Pack Grow Window Vertically
Window Lower=none,none,Lower Window
Window Maximize=Meta+Up,Meta+PgUp,Maximize Window
Window Maximize Horizontal=none,none,Maximize Window Horizontally
Window Maximize Vertical=none,none,Maximize Window Vertically
Window Minimize=Meta+PgDown,Meta+PgDown,Minimize Window
Window Move=none,none,Move Window
Window No Border=none,none,Hide Window Border
Window On All Desktops=none,none,Keep Window on All Desktops
Window One Desktop Down=Ctrl+Alt+Shift+Down,none,Window One Desktop Down
Window One Desktop Up=Ctrl+Alt+Shift+Up,none,Window One Desktop Up
Window One Desktop to the Left=none,none,Window One Desktop to the Left
Window One Desktop to the Right=none,none,Window One Desktop to the Right
Window Operations Menu=Alt+F3,Alt+F3,Window Operations Menu
Window Pack Down=none,none,Pack Window Down
Window Pack Left=none,none,Pack Window to the Left
Window Pack Right=none,none,Pack Window to the Right
Window Pack Up=none,none,Pack Window Up
Window Quick Tile Bottom=,Meta+Down,Quick Tile Window to the Bottom
Window Quick Tile Bottom Left=none,none,Quick Tile Window to the Bottom Left
Window Quick Tile Bottom Right=none,none,Quick Tile Window to the Bottom Right
Window Quick Tile Left=Meta+Left,Meta+Left,Quick Tile Window to the Left
Window Quick Tile Right=Meta+Right,Meta+Right,Quick Tile Window to the Right
Window Quick Tile Top=,Meta+Up,Quick Tile Window to the Top
Window Quick Tile Top Left=none,none,Quick Tile Window to the Top Left
Window Quick Tile Top Right=none,none,Quick Tile Window to the Top Right
Window Raise=none,none,Raise Window
Window Resize=none,none,Resize Window
Window Shade=none,none,Shade Window
Window Shrink Horizontal=none,none,Pack Shrink Window Horizontally
Window Shrink Vertical=none,none,Pack Shrink Window Vertically
Window to Desktop 1=none,none,Window to Desktop 1
Window to Desktop 10=none,none,Window to Desktop 10
Window to Desktop 11=none,none,Window to Desktop 11
Window to Desktop 12=none,none,Window to Desktop 12
Window to Desktop 13=none,none,Window to Desktop 13
Window to Desktop 14=none,none,Window to Desktop 14
Window to Desktop 15=none,none,Window to Desktop 15
Window to Desktop 16=none,none,Window to Desktop 16
Window to Desktop 17=none,none,Window to Desktop 17
Window to Desktop 18=none,none,Window to Desktop 18
Window to Desktop 19=none,none,Window to Desktop 19
Window to Desktop 2=none,none,Window to Desktop 2
Window to Desktop 20=none,none,Window to Desktop 20
Window to Desktop 3=none,none,Window to Desktop 3
Window to Desktop 4=none,none,Window to Desktop 4
Window to Desktop 5=none,none,Window to Desktop 5
Window to Desktop 6=none,none,Window to Desktop 6
Window to Desktop 7=none,none,Window to Desktop 7
Window to Desktop 8=none,none,Window to Desktop 8
Window to Desktop 9=none,none,Window to Desktop 9
Window to Next Desktop=none,none,Window to Next Desktop
Window to Next Screen=Meta+Return,none,Window to Next Screen
Window to Previous Desktop=none,none,Window to Previous Desktop
Window to Previous Screen=none,none,Window to Previous Screen
Window to Screen 0=none,none,Window to Screen 0
Window to Screen 1=none,none,Window to Screen 1
Window to Screen 2=none,none,Window to Screen 2
Window to Screen 3=none,none,Window to Screen 3
Window to Screen 4=none,none,Window to Screen 4
Window to Screen 5=none,none,Window to Screen 5
Window to Screen 6=none,none,Window to Screen 6
Window to Screen 7=none,none,Window to Screen 7
_k_friendly_name=KWin
view_actual_size=,Meta+0,Actual Size
view_zoom_in=Meta+=,Meta+=,Zoom In
view_zoom_out=Meta+-,Meta+-,Zoom Out
```



# v2

```
[org.flameshot.Flameshot.desktop]
Capture=Ctrl+Print,,Take screenshot
Configure=,,Configure
Launcher=,,Open launcher
_k_friendly_name=Flameshot
_launch=,,Flameshot

[kwin]
Activate Window Demanding Attention=Ctrl+Alt+A,Ctrl+Alt+A,Activate Window Demanding Attention
Decrease Opacity=none,none,Decrease Opacity of Active Window by 5 %
Expose=Meta+Tab,Ctrl+F9,Toggle Present Windows (Current desktop)
ExposeAll=Ctrl+F10\tLaunch (C),Ctrl+F10\tLaunch (C),Toggle Present Windows (All desktops)
ExposeClass=Ctrl+F7,Ctrl+F7,Toggle Present Windows (Window class)
Increase Opacity=none,none,Increase Opacity of Active Window by 5 %
Invert Screen Colors=none,none,Invert Screen Colors
Kill Window=Ctrl+Alt+Esc,Ctrl+Alt+Esc,Kill Window
MoveMouseToCenter=Meta+F6,Meta+F6,Move Mouse to Center
MoveMouseToFocus=Meta+F5,Meta+F5,Move Mouse to Focus
MoveZoomDown=none,none,Move Zoomed Area Downwards
MoveZoomLeft=none,none,Move Zoomed Area to Left
MoveZoomRight=none,none,Move Zoomed Area to Right
MoveZoomUp=none,none,Move Zoomed Area Upwards
Setup Window Shortcut=none,none,Setup Window Shortcut
Show Desktop=,Meta+D,Show Desktop
ShowDesktopGrid=Meta+Space,Ctrl+F8,Show Desktop Grid
Suspend Compositing=Alt+Shift+F12,Alt+Shift+F12,Suspend Compositing
Switch One Desktop Down=Ctrl+Alt+Down,Meta+Ctrl+Down,Switch One Desktop Down
Switch One Desktop Up=Ctrl+Alt+Up,Meta+Ctrl+Up,Switch One Desktop Up
Switch One Desktop to the Left=none,Meta+Ctrl+Left,Switch One Desktop to the Left
Switch One Desktop to the Right=none,Meta+Ctrl+Right,Switch One Desktop to the Right
Switch Window Down=Meta+Alt+Down,Meta+Alt+Down,Switch to Window Below
Switch Window Left=Meta+Alt+Left,Meta+Alt+Left,Switch to Window to the Left
Switch Window Right=Meta+Alt+Right,Meta+Alt+Right,Switch to Window to the Right
Switch Window Up=Meta+Alt+Up,Meta+Alt+Up,Switch to Window Above
Switch to Desktop 1=Ctrl+F1,Ctrl+F1,Switch to Desktop 1
Switch to Desktop 10=none,none,Switch to Desktop 10
Switch to Desktop 11=none,none,Switch to Desktop 11
Switch to Desktop 12=none,none,Switch to Desktop 12
Switch to Desktop 13=none,none,Switch to Desktop 13
Switch to Desktop 14=none,none,Switch to Desktop 14
Switch to Desktop 15=none,none,Switch to Desktop 15
Switch to Desktop 16=none,none,Switch to Desktop 16
Switch to Desktop 17=none,none,Switch to Desktop 17
Switch to Desktop 18=none,none,Switch to Desktop 18
Switch to Desktop 19=none,none,Switch to Desktop 19
Switch to Desktop 2=Ctrl+F2,Ctrl+F2,Switch to Desktop 2
Switch to Desktop 20=none,none,Switch to Desktop 20
Switch to Desktop 3=Ctrl+F3,Ctrl+F3,Switch to Desktop 3
Switch to Desktop 4=Ctrl+F4,Ctrl+F4,Switch to Desktop 4
Switch to Desktop 5=none,none,Switch to Desktop 5
Switch to Desktop 6=none,none,Switch to Desktop 6
Switch to Desktop 7=none,none,Switch to Desktop 7
Switch to Desktop 8=none,none,Switch to Desktop 8
Switch to Desktop 9=none,none,Switch to Desktop 9
Switch to Next Desktop=none,none,Switch to Next Desktop
Switch to Next Screen=,none,Switch to Next Screen
Switch to Previous Desktop=none,none,Switch to Previous Desktop
Switch to Previous Screen=none,none,Switch to Previous Screen
Switch to Screen 0=none,none,Switch to Screen 0
Switch to Screen 1=none,none,Switch to Screen 1
Switch to Screen 2=none,none,Switch to Screen 2
Switch to Screen 3=none,none,Switch to Screen 3
Switch to Screen 4=none,none,Switch to Screen 4
Switch to Screen 5=none,none,Switch to Screen 5
Switch to Screen 6=none,none,Switch to Screen 6
Switch to Screen 7=none,none,Switch to Screen 7
Toggle Night Color=none,none,Toggle Night Color
Toggle Window Raise/Lower=none,none,Toggle Window Raise/Lower
Walk Through Desktop List=none,none,Walk Through Desktop List
Walk Through Desktop List (Reverse)=none,none,Walk Through Desktop List (Reverse)
Walk Through Desktops=none,none,Walk Through Desktops
Walk Through Desktops (Reverse)=none,none,Walk Through Desktops (Reverse)
Walk Through Windows=Alt+Tab,Alt+Tab,Walk Through Windows
Walk Through Windows (Reverse)=Alt+Shift+Backtab,Alt+Shift+Backtab,Walk Through Windows (Reverse)
Walk Through Windows Alternative=none,none,Walk Through Windows Alternative
Walk Through Windows Alternative (Reverse)=none,none,Walk Through Windows Alternative (Reverse)
Walk Through Windows of Current Application=Alt+`,Alt+`,Walk Through Windows of Current Application
Walk Through Windows of Current Application (Reverse)=Alt+~,Alt+~,Walk Through Windows of Current Application (Reverse)
Walk Through Windows of Current Application Alternative=none,none,Walk Through Windows of Current Application Alternative
Walk Through Windows of Current Application Alternative (Reverse)=none,none,Walk Through Windows of Current Application Alternative (Reverse)
Window Above Other Windows=none,none,Keep Window Above Others
Window Below Other Windows=none,none,Keep Window Below Others
Window Close=Alt+F4,Alt+F4,Close Window
Window Fullscreen=none,none,Make Window Fullscreen
Window Grow Horizontal=none,none,Pack Grow Window Horizontally
Window Grow Vertical=none,none,Pack Grow Window Vertically
Window Lower=none,none,Lower Window
Window Maximize=Meta+Up,Meta+PgUp,Maximize Window
Window Maximize Horizontal=none,none,Maximize Window Horizontally
Window Maximize Vertical=none,none,Maximize Window Vertically
Window Minimize=Meta+PgDown,Meta+PgDown,Minimize Window
Window Move=none,none,Move Window
Window No Border=none,none,Hide Window Border
Window On All Desktops=none,none,Keep Window on All Desktops
Window One Desktop Down=Ctrl+Alt+Shift+Down,Meta+Ctrl+Shift+Down,Window One Desktop Down
Window One Desktop Up=Ctrl+Alt+Shift+Up,Meta+Ctrl+Shift+Up,Window One Desktop Up
Window One Desktop to the Left=none,Meta+Ctrl+Shift+Left,Window One Desktop to the Left
Window One Desktop to the Right=none,Meta+Ctrl+Shift+Right,Window One Desktop to the Right
Window Operations Menu=Alt+F3,Alt+F3,Window Operations Menu
Window Pack Down=none,none,Pack Window Down
Window Pack Left=none,none,Pack Window to the Left
Window Pack Right=none,none,Pack Window to the Right
Window Pack Up=none,none,Pack Window Up
Window Quick Tile Bottom=,Meta+Down,Quick Tile Window to the Bottom
Window Quick Tile Bottom Left=none,none,Quick Tile Window to the Bottom Left
Window Quick Tile Bottom Right=none,none,Quick Tile Window to the Bottom Right
Window Quick Tile Left=Meta+Left,Meta+Left,Quick Tile Window to the Left
Window Quick Tile Right=Meta+Right,Meta+Right,Quick Tile Window to the Right
Window Quick Tile Top=,Meta+Up,Quick Tile Window to the Top
Window Quick Tile Top Left=none,none,Quick Tile Window to the Top Left
Window Quick Tile Top Right=none,none,Quick Tile Window to the Top Right
Window Raise=none,none,Raise Window
Window Resize=none,none,Resize Window
Window Shade=none,none,Shade Window
Window Shrink Horizontal=none,none,Pack Shrink Window Horizontally
Window Shrink Vertical=none,none,Pack Shrink Window Vertically
Window to Desktop 1=none,none,Window to Desktop 1
Window to Desktop 10=none,none,Window to Desktop 10
Window to Desktop 11=none,none,Window to Desktop 11
Window to Desktop 12=none,none,Window to Desktop 12
Window to Desktop 13=none,none,Window to Desktop 13
Window to Desktop 14=none,none,Window to Desktop 14
Window to Desktop 15=none,none,Window to Desktop 15
Window to Desktop 16=none,none,Window to Desktop 16
Window to Desktop 17=none,none,Window to Desktop 17
Window to Desktop 18=none,none,Window to Desktop 18
Window to Desktop 19=none,none,Window to Desktop 19
Window to Desktop 2=none,none,Window to Desktop 2
Window to Desktop 20=none,none,Window to Desktop 20
Window to Desktop 3=none,none,Window to Desktop 3
Window to Desktop 4=none,none,Window to Desktop 4
Window to Desktop 5=none,none,Window to Desktop 5
Window to Desktop 6=none,none,Window to Desktop 6
Window to Desktop 7=none,none,Window to Desktop 7
Window to Desktop 8=none,none,Window to Desktop 8
Window to Desktop 9=none,none,Window to Desktop 9
Window to Next Desktop=none,none,Window to Next Desktop
Window to Next Screen=Meta+Return,Meta+Shift+Right,Window to Next Screen
Window to Previous Desktop=none,none,Window to Previous Desktop
Window to Previous Screen=none,Meta+Shift+Left,Window to Previous Screen
Window to Screen 0=none,none,Window to Screen 0
Window to Screen 1=none,none,Window to Screen 1
Window to Screen 2=none,none,Window to Screen 2
Window to Screen 3=none,none,Window to Screen 3
Window to Screen 4=none,none,Window to Screen 4
Window to Screen 5=none,none,Window to Screen 5
Window to Screen 6=none,none,Window to Screen 6
Window to Screen 7=none,none,Window to Screen 7
_k_friendly_name=KWin
addDesktop=none,none,Virtual Desktop Bar - Add Desktop
moveCurrentDesktopToLeft=none,none,Virtual Desktop Bar - Move Current Desktop to Left
moveCurrentDesktopToRight=none,none,Virtual Desktop Bar - Move Current Desktop to Right
removeCurrentDesktop=none,none,Virtual Desktop Bar - Remove Current Desktop
removeLastDesktop=none,none,Virtual Desktop Bar - Remove Last Desktop
renameCurrentDesktop=none,none,Virtual Desktop Bar - Rename Current Desktop
switchToRecentDesktop=none,none,Virtual Desktop Bar - Switch to Recent Desktop
view_actual_size=,Meta+0,Actual Size
view_zoom_in=Meta+=,Meta+=,Zoom In
view_zoom_out=Meta+-,Meta+-,Zoom Out
```