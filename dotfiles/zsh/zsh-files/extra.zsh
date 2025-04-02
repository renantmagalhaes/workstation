# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')
linux_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')

# Aliases

alias sdm="sdm.exe"
