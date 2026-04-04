#!/bin/bash

# Ensure the script is run as root
[[ $EUID -ne 0 ]] && echo "Please run as root" && exit 1

LIST_FILE="/etc/apt/sources.list"

echo "--- Intelligent Debian -> Sid Migration ---"

# 1. Backup with timestamp
BACKUP_NAME="${LIST_FILE}.bak.$(date +%F_%T)"
cp "$LIST_FILE" "$BACKUP_NAME"
echo "Backup created: $BACKUP_NAME"

# 2. The 'Smarter' Sed
# This regex looks for lines starting with 'deb' or 'deb-src',
# skips the URL (field 2), and replaces the suite (field 3) with 'sid'.
# It specifically targets the main debian.org lines.
echo "Swapping current release suite for 'sid'..."
sed -i -E '/^deb(-src)? http/ s/^([^ ]+ +[^ ]+ +)[^ ]+/\1sid/' "$LIST_FILE"

# 3. Handle Security and Updates
# These are redundant/broken in Sid. We comment them out if they aren't already.
echo "Disabling security and updates repositories (redundant in Sid)..."
sed -i -E '/security|updates/ s/^([^#])/# \1/' "$LIST_FILE"

# 4. Cleanup redundant tags (like your double non-free-firmware)
echo "Cleaning up duplicate tags..."
sed -i 's/non-free-firmware non-free-firmware/non-free-firmware/g' "$LIST_FILE"

echo "--- Review your new sources.list ---"
cat "$LIST_FILE"
echo "------------------------------------"

# 5. Execution
read -p "Does this look correct? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  apt update
  # Install safety tools before the heavy lifting
  apt install -y apt-listbugs apt-listchanges
  # The actual migration
  apt full-upgrade -y
  echo "Migration complete. Please reboot."
else
  echo "Aborted. Restoring backup..."
  mv "$BACKUP_NAME" "$LIST_FILE"
fi
