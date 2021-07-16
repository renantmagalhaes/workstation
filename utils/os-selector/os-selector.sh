# Select DEB or RPM system

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}


if check_cmd apt-get; then # FOR DEB SYSTEMS
    bash desktop/0-DEB/0-system.sh
elif check_cmd dnf; then  # FOR RPM SYSTEMS
     bash desktop/1-RPM/0-system.sh
else
    echo "Not able to identify the system"
fi