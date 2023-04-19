# G810-led

If installed via distro repository, enable systemd

```bash
systemctl enable g810-led.service --now
```

Test profile

```bash
sudo g810-led -p sample/rtm-minimal
```

Enable profile

```bash
sudo bash -c 'cat << EOF > /etc/g810-led/profile
# Custom Keys
k play ff7700 # #ff7700
k print_screen ff7700 # #ff7700
k tilde ff00ff # #ff00ff
k escape ff0000     # #ff0000

# Logo
g logo FFFFFF # #FFFFFF


g indicators 00FFD8     # #00FFD8
g multimedia DCE821     # #DCE821
g fkeys 52F352          # #52F352
g modifiers FFFFFF      # #FFFFFF
g arrows B082D9         # #B082D9
g numeric B082D9        # #B082D9
g functions 52F352      # #52F352
g keys B082D9           # #B082D9
g gkeys 0000FF          # #0000FF 

c                   # Commit changes
EOF'
```
