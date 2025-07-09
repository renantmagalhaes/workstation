#!/bin/bash

# A function to check if a command is available on the system.
# It redirects both stdout and stderr to /dev/null to run silently.
check_cmd() {
	command -v "$1" &>/dev/null
}

# --- Main Script ---

# Display the user menu
echo "Please select which VPN you would like to install:"
echo "  1) Install NordVPN"
echo "  2) Install Windscribe"
echo "  3) Install ProtonVPN"
read -p "Enter your choice [1, 2, or 3]: " choice

# Use a case statement to act on the user's choice
case $choice in
1)
	echo "🔹 Preparing to install NordVPN..."
	if check_cmd apt-get; then
		echo "Debian-based system detected."
		echo "Running NordVPN installation steps for Debian/Ubuntu..."
		# --- ADD DEBIAN/UBUNTU NORDVPN COMMANDS HERE ---
		sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
		sudo apt install -y nordvpn-gui
		sudo usermod -aG nordvpn $USER
		sudo systemctl enable --now nordvpnd.service
		sudo nordvpn set lan-discovery enabled
		sudo nordvpn whitelist add port 53

	elif check_cmd zypper; then
		echo "openSUSE-based system detected."
		echo "Running NordVPN installation steps for openSUSE..."
		# --- ADD openSUSE NORDVPN COMMANDS HERE ---
		sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
		sudo zypper install -y nordvpn-gui
		sudo usermod -aG nordvpn $USER
		sudo systemctl enable --now nordvpnd.service
		nordvpn set lan-discovery enabled
		nordvpn whitelist add port 53
	else
		echo "❌ Error: Unsupported operating system. Cannot install NordVPN."
		exit 1
	fi
	;;

2)
	echo "🔹 Preparing to install Windscribe..."
	if check_cmd apt-get; then
		echo "Debian-based system detected."
		echo "Running Windscribe installation steps for Debian/Ubuntu..."
		# --- ADD DEBIAN/UBUNTU WINDSCRIBE COMMANDS HERE ---
		curl -L -o /tmp/windscribe.deb https://windscribe.com/install/desktop/linux_deb_x64
		sudo dpkg -i /tmp/windscribe.deb

	elif check_cmd zypper; then
		echo "openSUSE-based system detected."
		echo "Running Windscribe installation steps for openSUSE..."
		# --- ADD openSUSE WINDSCRIBE COMMANDS HERE ---
		curl -L -o /tmp/windscribe.rpm https://windscribe.com/install/desktop/linux_rpm_opensuse_x64
		sudo rpm -i /tmp/windscribe.rpm

	else
		echo "❌ Error: Unsupported operating system. Cannot install Windscribe."
		exit 1
	fi
	;;

3)
	echo "🔹 Preparing to install ProtonVPN..."
	if check_cmd apt-get; then
		echo "Debian-based system detected."
		echo "Running ProtonVPN installation steps for Debian/Ubuntu..."
		# --- ADD DEBIAN/UBUNTU PROTONVPN COMMANDS HERE ---
		curl -L -o /tmp/protonvpn-stable.deb https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
		sudo dpkg -i /tmp/protonvpn-stable.deb && sudo apt update
		sudo apt install proton-vpn-gnome-desktop

	elif check_cmd zypper; then
		echo "openSUSE-based system detected."
		echo "Running ProtonVPN installation steps for openSUSE..."
		# --- ADD openSUSE PROTONVPN COMMANDS HERE ---
		sudo zypper install -y protonvpn-cli protonvpn-gui

	else
		echo "❌ Error: Unsupported operating system. Cannot install ProtonVPN."
		exit 1
	fi
	;;

*)
	echo "❗ Invalid selection. Please run the script again and choose 1, 2, or 3."
	exit 1
	;;
esac

echo "✅ Script finished."
exit 0
