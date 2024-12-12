# KDE

# Themes

# System Settings

- Application Style
  - Configure GNOME/GTK
- Desktop effects
  - Overview (assign shortcut if necessary)
  - Enable Blur
  - Dim Screen for Administrator Mode
  - Slide Back
  - Enable Magic Lamp
    - Animation 170ms
  <!-- - Enable Wobby Windows -->
    <!-- - Uncheck Wobbly when resizing. -->
- Task Switcher
  - Thumbnail Grid
- Virtual Desktops
  - Let only 1 row
    - add 5 desktops
  - Disable Navigation Wraps Around
  - Top left corner
    - Overview
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

## KWin Scripts

- Force Blur
- Window Gaps (bismuth)
- Hide all title bars (window rules)
  ![alt text](../../assets/hide-all-titleBars.png)

## Extra 
- AutoStart

![alt text](../../assets/autostartkde.png)

```
flatpak run com.core447.StreamController

flatpak run com.github.hluk.copyq
```


### Widgets

- Actove Window Control
- Menu11
- Virtual Desktop Bar(https://github.com/wsdfhjxc/virtual-desktop-bar)




### KDE top scroll bar (replaces by pixel perfect polybar)
<!-- 1. Add commond empty panel
2. Edit ~/.config/plasma-org.kde.plasma.desktop-appletsrc
   1. add under [ActionPlugins][1]
      1. wheel:Vertical;NoModifier=org.kde.switchdesktop
3. Keyboard and shortcut for menu -> Alt + F1
4. Disable notification system tray (top panel)
5. Change ~/.config/plasmashellrc
   1. thickness=5 to thickness=3 --> -->


# Set KRunner shortcut to meta key and config

```
kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.krunner,/App,,toggleDisplay"
qdbus-qt5 org.kde.KWin /KWin reconfigure
qdbus org.kde.KWin /KWin reconfigure
```

- Disable desktop search