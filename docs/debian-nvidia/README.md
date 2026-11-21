# Debian 13 + NVIDIA + MangoWM (Wayland)

Everything that worked when setting up a Lenovo ThinkPad (Intel TigerLake + NVIDIA RTX A2000 Mobile,
hybrid graphics, Secure Boot on) running Debian 13 (trixie) with MangoWM and two external monitors.
Only the steps that worked are listed.

`setup.sh` in this folder automates steps 1-3. Steps 4 and 5 are manual.

## Symptoms this fixes

- Display very slow right after installing Debian (the open-source `nouveau` driver is in use).
- After installing the NVIDIA driver: no MOK screen at boot, external monitors dead.
- MangoWM missing from the GDM session list (only GNOME offered).
- Flicker, lag, black laptop screen or crashes with external monitors wired to the NVIDIA GPU.

## 0. Check the hardware

```bash
lspci -nnk | grep -A3 -Ei 'vga|3d|display'   # shows Intel + NVIDIA, and which driver is bound
mokutil --sb-state                            # "SecureBoot enabled" means the module must be signed
grep -E '^deb' /etc/apt/sources.list          # needs: main contrib non-free non-free-firmware
```

## 1. Install the driver (DKMS)

```bash
sudo apt update
sudo apt install linux-headers-amd64 nvidia-driver firmware-misc-nonfree
```

This installs 550.x and builds `nvidia-current` through DKMS, signed with `/var/lib/dkms/mok.key`.

## 2. Enroll the signing key (Secure Boot)

The MOK prompt did **not** appear automatically during install, so the module was built but never loaded.
Queue the enrollment by hand:

```bash
sudo mokutil --import /var/lib/dkms/mok.pub    # choose a throwaway password, asked twice
mokutil --list-new                              # should list the key
sudo reboot
```

At boot the blue **MOK Manager** screen appears (about 10 seconds): *Enroll MOK, Continue, Yes*, enter the
password, *Reboot*. Forgot the password? `sudo mokutil --revoke-import` and import again.

Verify after reboot:

```bash
nvidia-smi
ls -l /dev/dri/by-path/
```

## 3. Make GDM offer Wayland sessions (MangoWM)

Debian's `61-gdm.rules` disables Wayland whenever the NVIDIA driver is present, unless the NVIDIA power
management is configured. Until then GDM only lists GNOME on Xorg.

```bash
echo 'options nvidia-current NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power.conf
echo 'options nvidia-drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia-drm.conf
sudo systemctl enable nvidia-suspend nvidia-resume nvidia-hibernate
sudo update-initramfs -u
sudo reboot
```

`modeset=1` is required by wlroots compositors. Afterwards pick **Mango** from the gear icon on the login screen.

## 4. BIOS: switch to Discrete Graphics (the real fix for external monitors)

On the laptop the external ports are wired to the NVIDIA GPU. In hybrid mode wlroots renders on Intel and
copies frames to NVIDIA, which caused lag, flicker, a black laptop panel and compositor crashes.

1. Reboot, press **F1**, then *Config > Display > Graphics Device* and set **Discrete Graphics**.
2. Save and reboot.

Now NVIDIA is the only GPU (`/dev/dri/by-path/` shows a single card), the laptop panel and all outputs go
through it, and MangoWM needs **no** `WLR_DRM_DEVICES` and no launcher wrapper. The session file keeps its
stock `Exec=mango`. Cost: higher battery use, so this suits docked use.

## Troubleshooting

| Problem | Check |
|---|---|
| `nvidia-smi` cannot talk to the driver | MOK not enrolled: `mokutil --list-enrolled`. Redo step 2. |
| Mango missing at GDM | Redo step 3, then `systemctl restart gdm3`. |
| Back at GDM right after login | `WLR_DRM_DEVICES` points at a card that no longer exists. Remove it, or use `ls -l /dev/dri/by-path/`. |
| Monitors not found in the config | `wlr-randr` for the real names; port numbers change when the GPU mode changes. |
| Need to read GDM logs | `sudo usermod -aG systemd-journal,adm $USER`, then log in again. |

## Not recommended (tried, did not work well)

- Hybrid graphics with NVIDIA as primary (`WLR_DRM_DEVICES=card1:card0`): black laptop panel,
  `Failed to pick cursor plane format` errors, crashes when dragging windows.
- Hybrid with Intel as primary: externals lag and flicker because every frame is copied to NVIDIA.
- Disabling the laptop panel with a live config reload while in hybrid mode crashed the compositor.
  In discrete mode the same hot reload was fine.
