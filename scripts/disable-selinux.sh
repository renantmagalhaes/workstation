#Disable SELinux
CONFIG="/etc/selinux/config"

# 1) Immediate runtime: set to permissive
if command -v selinuxenabled &>/dev/null && selinuxenabled; then
	echo "→ Setting SELinux to permissive mode now"
	if command -v setenforce &>/dev/null; then
		setenforce 0
	else
		echo "⚠️ setenforce command not found; skipping runtime change"
	fi
else
	echo "→ SELinux is already disabled or not present"
fi

# 2) Permanent on-next-boot: disable in config file
if [ -f "$CONFIG" ]; then
	echo "→ Backing up $CONFIG to ${CONFIG}.bak"
	cp -p "$CONFIG" "${CONFIG}.bak"

	# Replace any existing SELINUX= lines
	echo "→ Writing SELINUX=disabled to $CONFIG"
	sed -ri 's/^SELINUX=.*/SELINUX=disabled/' "$CONFIG"
else
	echo "⚠️ Config file $CONFIG not found; cannot disable SELinux permanently"
	exit 1
fi
