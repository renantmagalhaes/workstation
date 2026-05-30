#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GtkLayerShell
import os
import time
import sys

# Script settings
SCRIPT_PATH = "/home/rtm/.dotfiles/mangowm/scripts/toggle_all_overviews.sh"
HOTAREA_SIZE = 10  # pixels

windows = []
last_trigger_time = 0.0

def on_enter(widget, event):
    global last_trigger_time
    now = time.monotonic()
    
    # Check if we were already in the hotarea (prevent duplicate triggers)
    if not getattr(widget, "is_in_hotarea", False):
        widget.is_in_hotarea = True
        # Cooldown trigger within 1.0s
        if now - last_trigger_time > 1.0:
            last_trigger_time = now
            os.system(f"{SCRIPT_PATH} &")
    return True

def on_leave(widget, event):
    widget.is_in_hotarea = False
    return True


def create_hotarea_window(monitor):
    win = Gtk.Window()
    # Request transparency
    screen = win.get_screen()
    visual = screen.get_rgba_visual()
    if visual and screen.is_composited():
        win.set_visual(visual)
    win.set_app_paintable(True)
    
    # Initialize GtkLayerShell
    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_monitor(win, monitor)
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    # Set to -1 to not reserve space
    GtkLayerShell.set_exclusive_zone(win, -1)
    
    # Anchor to TOP and LEFT only
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.LEFT, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.RIGHT, False)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.BOTTOM, False)
    
    # We want it to receive pointer events but not keyboard focus
    GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.NONE)
    
    # Request the target hotarea size
    win.set_size_request(HOTAREA_SIZE, HOTAREA_SIZE)
    
    # Track pointer entry and exit
    win.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK)
    win.connect("enter-notify-event", on_enter)
    win.connect("leave-notify-event", on_leave)
    win.is_in_hotarea = False
    
    win.show_all()
    return win

def update_monitors(display):
    global windows
    # Clean up old windows
    for win in windows:
        win.destroy()
    windows.clear()
    
    n_monitors = display.get_n_monitors()
    for i in range(n_monitors):
        monitor = display.get_monitor(i)
        win = create_hotarea_window(monitor)
        windows.append(win)

def main():
    display = Gdk.Display.get_default()
    if not display:
        print("Error: Could not open Wayland display", file=sys.stderr)
        sys.exit(1)
        
    # Initial creation of windows
    update_monitors(display)
    
    # Update windows if monitors change
    display.connect("monitor-added", lambda d, m: update_monitors(d))
    display.connect("monitor-removed", lambda d, m: update_monitors(d))
    
    # Start the main loop
    Gtk.main()

if __name__ == "__main__":
    main()
