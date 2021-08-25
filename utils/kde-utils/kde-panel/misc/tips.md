# Reddit

## [option 1](https://www.reddit.com/r/kde/comments/4rj3fp/question_about_switching_workspaces_with_mouse/)


Quit plasmashell and then open your ~/.config/plasma-org.kde.plasma.desktop-appletsrc (create a backup of that file first!). Look through the available containments and see which one is your panel.

My panel for example is:

[Containments][1]
```
plugin=org.kde.panel
```
Take note of the number, 1 in this case. Now look for a
```
[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu
```
with the correct number. If it doesn't exist, create it but it should really be in that file somewhere. Now add the following afterwards:
```
wheel:Vertical;NoModifier=org.kde.switchdesktop
```
Restart plasma, et voila, you can change virtual desktops by mouse wheeling your panel. Note that you might need to disable switching windows by wheel in task manager settings and that some applets (like volume) intercept wheel events. In theory you could add any containment action that is available in "Mouse Actions" in the wallpaper settings dialog.

Edit: I just noticed that the task manager eats wheel events even if this option is disabled. :/ I'll have a look why that is.

## [option 2](https://www.reddit.com/r/kde/comments/4rj3fp/question_about_switching_workspaces_with_mouse/)
Scroll over the pager widget. Scroll over the wallpaper (I disable this). The Task Manager Widget will cycle the open windows on scroll, which will switch to the workspace the window is on (personally I filter out windows on other workspaces).

If you think the pager uses too much space, you could try my win7 showdesktop widget which is like 10 pixels wide. Add it to a corner of the panel (make sure to lock the widgets afterward to hide the ☰ icon). You can configure the commands on scroll up/down to:

```
qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Left"

qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Right"
```  

# option 3

Back when I used xmonad I used super+mousewheel to switch between desktops. I never figured out how to do the same in KDE :(

    With mod button you steel have to touch keyboard. BUT on my mouse there is a button under thumb which I don't use for anything. Maybe I can make a key combination involving that button on mouse to do it. Thanks for idea!

# option 4

It can be done in viewport switch hotkeys. You can choose what mouse button (scroll directions are different buttons) at what edge(s) of screen do.


Oh. I meant Compiz. In CompizConfig Setting Manager you can do what I wrote.
And for KDE you can read other comments. There is an idea to make a hotkey to switch workspaces and you can bind them to mouse buttons with xbindkeys.