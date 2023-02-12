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

### Keyboard Manager (DEPRECATED)

![picture 3](../../images/20f09a24c72b356598d589a9403515ebc415f4c1c29440bc3545fccdf02ccbc4.png)  


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

# Fix alt-tab

System -> Multitasking -> Show Microsoft Edge tabs when snapping or pressing Alt + Tab -> Don't show tabs
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
- On Air Clock

# Rounded TB

![picture 1](../../images/5bcd0ad5cb5d3cbd5413f160c6ed1e4ba48db5e6684016b77c5a1ac783ef5ba4.png)  

# Clipboard Sync

First, Enable Clipboard Sync on Windows 10
To get started with this feature, you’ll need to enable clipboard syncing on your Windows PC. To do that, go to Settings > System > Clipboard. Toggle on “Sync Across Devices.”

Turn on "Sync Across Devices."

On that same page, scroll down a bit further and choose to “Automatically sync text that I copy.” This will ensure that it syncs without any extra work from you.

Enable "Automatically Sync Text That I Copy."

Next, Activate Clipboard Sync on Android
Now, we can move over to SwiftKey on your Android device. As of November 2021, the feature is available in the stable version. Download it from the Play Store and open the app after it installs.

Download Swiftkey.

You will be asked to set SwiftKey Beta as your default keyboard app. The app will walk you through the process of enabling and selecting SwiftKey as default.

Set Swiftkey as default.

Next, you need to sign in to SwiftKey with the same Microsoft account that you use on your Windows PC. Tap “Account” at the top of the Settings.

Tap "Account."

Then, select “Sign in with Microsoft.” The clipboard syncing doesn’t work with a Google account.

Sign in with your Microsoft account.

After you’re signed in, go back to the SwiftKey Settings and select “Rich Input.”

Select "Rich Input."

Go to “Clipboard.”

Select "Clipboard."

Now, we can toggle on “Sync Clipboard History.”

Turn on "Sync Clipboard History."

You will be asked to sign in to your Microsoft account again to verify. Tap “OK” to do so.

Tap "OK."

That’s the last step! From now on, any text that you copy on Android will be available in the Windows clipboard, and any text that you copy on Windows will be available on the Android clipboard. It works quite seamlessly.