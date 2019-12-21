#!/usr/bin/env bash

# ====================CONFIG THIS =============================== #
COLOR_01="#303030"           # HOST
COLOR_02="#e1321a"           # SYNTAX_STRING
COLOR_03="#8FFF57"           # COMMAND
COLOR_04="#ffc005"           # COMMAND_COLOR2
COLOR_05="#004f9e"           # PATH
COLOR_06="#ec0048"           # SYNTAX_VAR
COLOR_07="#2aa7e7"           # PROMP
COLOR_08="#f2f2f2"           #

COLOR_09="#5d5d5d"           #
COLOR_10="#ff361e"           # COMMAND_ERROR
COLOR_11="#50FA7B"           # EXEC
COLOR_12="#ffd00a"           #
COLOR_13="#3C6FAE"           # FOLDER
COLOR_14="#db3b4b"           #
COLOR_15="#4bb8fd"           #
COLOR_16="#ffffff"           #

BACKGROUND_COLOR="#101010"   # Background Color
FOREGROUND_COLOR="#f2f2f2"   # Text
CURSOR_COLOR="$FOREGROUND_COLOR" # Cursor
PROFILE_NAME="RTM"
# =============================================







# =============================================================== #
# | Apply Colors
# ===============================================================|#
function gogh_colors () {
    echo ""
    echo -e "\033[0;30m█████\\033[0m\033[0;31m█████\\033[0m\033[0;32m█████\\033[0m\033[0;33m█████\\033[0m\033[0;34m█████\\033[0m\033[0;35m█████\\033[0m\033[0;36m█████\\033[0m\033[0;37m█████\\033[0m"
    echo -e "\033[0m\033[1;30m█████\\033[0m\033[1;31m█████\\033[0m\033[1;32m█████\\033[0m\033[1;33m█████\\033[0m\033[1;34m█████\\033[0m\033[1;35m█████\\033[0m\033[1;36m█████\\033[0m\033[1;37m█████\\033[0m"
    echo ""
}

function curlsource() {
    f=$(mktemp -t curlsource)
    curl -o "$f" -s -L "$1"
    source "$f"
    rm -f "$f"
}

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_PATH="$(dirname "$SCRIPT_PATH")"

gogh_colors

if [ -e $PARENT_PATH"/apply-colors.sh" ]
then
    source $PARENT_PATH"/apply-colors.sh"
else
    if [ $(uname) = "Darwin" ]; then
        # OSX ships with curl and ancient bash
        # Note: here, sourcing directly from curl does not work
        curlsource https://raw.githubusercontent.com/Mayccoll/Gogh/master/apply-colors.sh
    else
        # Linux ships with wget
        source <(wget -O - https://raw.githubusercontent.com/Mayccoll/Gogh/master/apply-colors.sh)
    fi
fi
