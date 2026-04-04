#!/bin/bash

# Ensure the script is run as root
[[ $EUID -ne 0 ]] && echo "Please run as root" && exit 1

LIST_FILE="/etc/apt/sources.list"
TEMP_FILE=$(mktemp)

echo "--- V3: Ultra-Smart Debian -> Sid Migration ---"

# 1. Backup with timestamp
BACKUP_NAME="${LIST_FILE}.bak.$(date +%F_%T)"
cp "$LIST_FILE" "$BACKUP_NAME"
echo "Backup created: $BACKUP_NAME"

# 2. Process the file line-by-line to remove duplicates and swap to sid
echo "Processing repositories and removing duplicates..."

# We use a temporary file to rebuild the sources.list cleanly
declare -A SEEN_REPOS

while IFS= read -r line; do
  # Skip empty lines or lines that are already comments
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    echo "$line" >>"$TEMP_FILE"
    continue
  fi

  # Identify if it's a deb or deb-src line
  if [[ "$line" =~ ^deb(-src)? ]]; then

    # 1. Disable Security and Updates immediately
    if [[ "$line" =~ security\.debian\.org || "$line" =~ -updates ]]; then
      echo "# $line # Disabled for Sid" >>"$TEMP_FILE"
      continue
    fi

    # 2. Transform the suite to 'sid' (3rd field)
    # This regex swaps the suite name regardless of what it currently is
    new_line=$(echo "$line" | sed -E 's/^([^ ]+ +[^ ]+ +)[^ ]+/\1sid/')

    # 3. Clean up redundant firmware tags if present
    new_line=$(echo "$new_line" | sed 's/non-free-firmware non-free-firmware/non-free-firmware/g')

    # 4. Check for duplicates (using the whole line as a key)
    if [[ -z "${SEEN_REPOS[$new_line]}" ]]; then
      echo "$new_line" >>"$TEMP_FILE"
      SEEN_REPOS[$new_line]=1
    else
      echo "# $new_line # Removed Duplicate" >>"$TEMP_FILE"
    fi
  else
    # Keep non-deb lines (like comments or blank lines)
    echo "$line" >>"$TEMP_FILE"
  fi
done <"$LIST_FILE"

# Move the cleaned, sid-ified file into place
mv "$TEMP_FILE" "$LIST_FILE"

echo "--- Review your NEW cleaned sources.list ---"
cat "$LIST_FILE"
echo "--------------------------------------------"

# 3. Execution Phase
read -p "Does the output look clean (no duplicates)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Updating package database..."
  apt update

  echo "Installing safety tools (apt-listbugs, apt-listchanges)..."
  apt install -y apt-listbugs apt-listchanges

  echo "Starting Full Upgrade (2,000+ packages). Stand by..."
  apt full-upgrade -y

  echo "Success! Please reboot to finalize the migration to Sid."
else
  echo "Aborted. Restoring backup..."
  mv "$BACKUP_NAME" "$LIST_FILE"
fi
