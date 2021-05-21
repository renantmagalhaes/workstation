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
