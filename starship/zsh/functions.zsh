# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`
linux_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`

# Colormap
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

function ip-geolocation() {
    curl http://ip-api.com/json/$1 | jq .
}

### pw generator
function pw () {
    pwgen -sync "${1:-48}" -1 | if command -v pbcopy > /dev/null 2>&1; then pbcopy; else xclip; fi
}

### get weather
function weather () {
    curl "https://wttr.in/${1}"
}

### find alias
function find-folder () {
find $1 -type d -iname $2 -exec bat {} +
}

function find-file () {
find $1 -type f -iname $2 -exec bat {} +
}

## docker remove all

function docker-remove-all () {
    sudo docker stop $(sudo docker ps -aq)
    sudo docker rm $(sudo docker ps -aq)
    sudo docker rmi $(sudo docker images -q)
    sudo docker volume rm $(sudo docker volume ls -q)
    sudo docker network rm $(sudo docker network ls -q)
}