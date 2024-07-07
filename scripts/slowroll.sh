#!/bin/bash

# Check if is a OpenSuse distro# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

if check_cmd zypper; then
	echo "OpenSUSE detected"
else
	echo "OpenSUSE not detected"
	exit 1
fi

# Enable repo
shopt -s globstar && TMPSR=$(mktemp -d) && zypper --pkg-cache-dir=${TMPSR} download openSUSE-repos-Slowroll && zypper modifyrepo --all --disable && zypper install ${TMPSR}/**/openSUSE-repos-Slowroll*.rpm && zypper dist-upgrade

# Packman repo
zypper ar --refresh -p 70 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Slowroll/Essentials/ packman
