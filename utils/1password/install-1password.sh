#!/bin/bash


check_cmd() {
    command -v "$1" 2> /dev/null
}


# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -O /tmp/1password-latest.deb
    sudo dpkg -i /tmp/1password-latest.deb
    sudo apt-get -f install

elif check_cmd zypper; then  # FOR SUSE SYSTEMS
    wget https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm -O /tmp/1password-latest.rpm
    sudo rpm -i /tmp/1password-latest.rpm

else
    echo "Not able to identify the system"
    exit 0
fi

# # Fix vivaldi
sudo mkdir -p  /etc/1password
sudo cp utils/1password/custom_allowed_browsers /etc/1password/custom_allowed_browsers
sudo chown root:root /etc/1password/custom_allowed_browsers && sudo chmod 755 /etc/1password/custom_allowed_browsers

# Auto start
mkdir -p ~/.config/autostart/
bash -c 'cat << EOF > ~/.config/autostart/1password.desktop
[Desktop Entry]
Type=Application
Name=1password
Exec=/usr/bin/1password --silent
EOF'