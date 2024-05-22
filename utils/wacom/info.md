# Wacom

## Script usage

### Map to main monitor

```
./select-monitor.sh 0
```

### Map to secondary monitor

```
./select-monitor.sh 1
```

## List Wacom devices

```
xsetwacom --list devices

Wacom Intuos BT S Pad pad               id: 16  type: PAD       
Wacom Intuos BT S Pen stylus            id: 15  type: STYLUS  
```

## List active monitors

```
xrandr --listactivemonitors
Monitors: 2

 0: +*DP-1 2560/697x1440/393+0+0  DP-1
 1: +DP-2 1920/598x1080/336+2560+0  DP-2
```

## Map wacom to monitor

```
xsetwacom --set "16" MapToOutput DP-1
xsetwacom --set "15" MapToOutput DP-1
```
