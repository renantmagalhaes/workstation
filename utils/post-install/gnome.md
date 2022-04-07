# GNOME

- Sync extensions


- List of extensions

```
scroll-workspaces@gfxmonk.net          
Vitals@CoreCoding.com                                       
user-theme@gnome-shell-extensions.gcampax.github.com
openweather-extension@jenslody.de                 
workspace-indicator@gnome-shell-extensions.gcampax.github.com
SimplerOffMenu.kerkus@pm.me                         
windowoverlay-icons@sustmidown.centrum.cz
extensions-sync@elhan.io                 
desktop-scroller@brorlandi                                   
cpupower@mko-sl.de
arcmenu@arcmenu.com                                                   
sound-output-device-chooser@kgshank.net
remove-alt-tab-delay@daase.net
noannoyance@daase.net
status-area-horizontal-spacing@mathematical.coffee.gmail.com
unite@hardpixel.eu
blur-my-shell@aunetx
gsconnect@andyholmes.github.io
bluetooth-quick-connect@bjarosze.gmail.com
appindicatorsupport@rgcjonas.gmail.com
dash-to-panel@jderose9.github.com
transparent-shell@siroj42.github.io
just-perfection-desktop@just-perfection
```


## Theme edit

~/.themes/Graphite-dark/gnome-shell/gnome-shell.css

```
/* Top Bar */
#panel {
  background-color: black;
  font-weight: bold;
  height: 32px;
  color: rgba(255, 255, 255, 0.7);
  font-feature-settings: "tnum";
  transition-duration: 250ms;
  font-size: 11pt;
}

#panel .panel-corner {
  -panel-corner-radius: 0;
  -panel-corner-background-color: black;
  -panel-corner-border-width: 2px;
  -panel-corner-border-color: transparent;
  -panel-corner-opacity: 1;
  transition-duration: 250ms;
}

#panel .panel-button {
  -natural-hpadding: 12px;
  -minimum-hpadding: 6px;
  font-weight: bold;
  color: rgba(255, 255, 255, 0.945);
  transition-duration: 150ms;
  border-radius: 9999px;
  text-shadow: none;
  border: 2px solid transparent;
}
```