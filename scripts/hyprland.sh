
#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    echo "WiP"
elif check_cmd zypper; then  # FOR zypper SYSTEMS
  ## Main pkgs
  sudo zypper in hyprland -y

else
    echo "Not able to identify the system"
    exit 0
fi

