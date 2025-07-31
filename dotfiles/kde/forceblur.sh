#!/bin/bash

# Define the classes you want to exclude
excluded_classes=("plasmashell" "Thorium-browser" "kwin" "dolphin" "kate" "systemsettings" "")

# Define the window types you want to include to not be blurred
#you can remove "_NET_WM_WINDOW_TYPE_MENU" from this list if you also want blurring behind menus (context menus etc...)
included_types=("_NET_WM_WINDOW_TYPE_NORMAL")

# Array to keep track of windows that have been processed
processed_window_ids=()

while true; do

	# Get the current list of visible window IDs
	current_visible_windows=$(xdotool search --sync --onlyvisible --class ".*")

	# Loop through each window
	for window_id in $current_visible_windows; do
		# Check if this window has already been processed
		if [[ " ${processed_window_ids[@]} " =~ " ${window_id} " ]]; then
			continue
		fi

		# Get the class of the window
		window_class=$(xprop -id $window_id | awk '/WM_CLASS/{print $4}' | tr -d '"')

		# Get all window types
		window_types=$(xprop -id $window_id | awk -F= '/_NET_WM_WINDOW_TYPE\(ATOM\)/{gsub(/ /, "", $2); gsub(/"/, "", $2); print $2}')

		# Check if the class is in the excluded list
		is_excluded=false
		for excluded_class in "${excluded_classes[@]}"; do
			if [[ $window_class == "$excluded_class" ]]; then
				is_excluded=true
				break
			fi
		done

		IFS=',' read -ra window_types <<<"$window_types"

		# Check if any of the window types are in the included list
		is_included=false
		for wtype in ${window_types[@]}; do
			#echo "$wtype"
			for included_type in "${included_types[@]}"; do
				if [[ "$wtype" == "$included_type" ]]; then
					is_included=true
					break 2 # Break both loops if a match is found
				fi
			done
		done

		# If not excluded and included, blur the window
		if [ "$is_excluded" != true ] && [ "$is_included" == true ]; then
			xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 1 -id "$window_id"
			echo "Blurring window with class: |$window_class| and types: |$window_types|"
		fi

		# Add this window to the processed list
		processed_window_ids+=("$window_id")
	done

	sleep 0.1
done
