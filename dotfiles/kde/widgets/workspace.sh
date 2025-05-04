#!/bin/bash

# Get number of desktops using wmctrl
num=$(wmctrl -d | wc -l)

# Get current desktop using qdbus6 (1-based)
current=$(qdbus6 org.kde.KWin /KWin currentDesktop 2>/dev/null)

# Validate numeric values
if ! [[ "$num" =~ ^[0-9]+$ && "$current" =~ ^[0-9]+$ ]]; then
	echo "n/a"
	exit 1
fi

# Unicode circles
FILLED="●"
EMPTY="○"

output=""
for i in $(seq 1 "$num"); do
	if [[ "$i" == "$current" ]]; then
		output+="$FILLED "
	else
		output+="$EMPTY "
	fi
done

# Trim trailing space
echo "  ${output%" "}  "
