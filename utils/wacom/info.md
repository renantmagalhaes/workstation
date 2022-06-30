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

 0: +*DisplayPort-0 2560/697x1440/393+0+0  DisplayPort-0
 1: +HDMI-A-0 1920/598x1080/336+2560+0  HDMI-A-0
```

## Map wacom to monitor 

```
xsetwacom --set "16" MapToOutput DisplayPort-0
xsetwacom --set "15" MapToOutput DisplayPort-0
```


