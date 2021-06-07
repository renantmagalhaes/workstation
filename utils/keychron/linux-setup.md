# Keychron Functions keys in Linux

## Automatic mode
```
[Repository](https://github.com/adam-savard/keychron-k2-function-keys-linux)
```

## Manual mode

- Fn + X + L  (hold 4 seconds)

- Fn + K + C (hold 4 seconds)


```
echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf

```

```
 sudo update-initramfs -u
```

# Bluetooth fast reconnect
```
Set "FastConnectable" to true in /etc/bluetooth/main.conf

```

# Shortcuts

```
FN + B | battery level (RGB versions - if the power above 70%, the charging indicator is green; 30%~70 %, the charging indicator will be blue; when it is under 30%, the charging indicator will keep flashing.)

FN + + | faster leds

FN + - | slower leds

FN + S + O (4 seconds) | disable auto-sleep mode

FN + X + L (4 seconds) | switch between function and multimedia keys

FN + J + Z (4 seconds) | factory reset

FN + Left/Right Arrow | change LED Colours for current effect

FN + Caps Lock + P | hold these three keys together for 6 seconds, The Caps Lock key will no longer follow the backlight mode, it will be used to indicate the status of capital/ small letters. Repeate to return to following other keys'

FN + L + Light | hold these three keys together for 6 seconds it will lock the light effect you are using now. To unlock the light effect, press these three keys together for 6 seconds again. Please make sure to hold the fn and L key first then hold the light effect key.

FN + I + D | hold these three keys together for 6 seconds, the function of the del key will be reversed to insert. Then the short press the key to get insert, press fn key combination will get the del function. Hold these three keys together for 6 seconds again to change back to the default.

FN + S + L + R | set the auto sleep time to 10 mins

FN + S + L + T | set the auto sleep time to 20 mins

FN + S + L + Y | set the auto sleep time to 30 mins

FN + Light | turn lights on / off

FN + Q (4 seconds) | activate discoverable mode

FN + 1 / 2 / 3 | change connected device (up to 3 devices)
```