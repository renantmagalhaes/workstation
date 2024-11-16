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

### pw generator
function pw () {
    pwgen -sync "${1:-48}" -1 | if command -v pbcopy > /dev/null 2>&1; then pbcopy; else xclip; fi
}

### get weather
function weather () {
    curl "https://wttr.in/${1}"
}

function ip-geolocation() {
    curl http://ip-api.com/json/$1 | jq .
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

## docker update compose

function docker-compose-update-images () {
    { echo "~~ $(date) ~~"; docker images; } >> ~/dockerImages.log
    docker compose pull
    docker compose up -d --force-recreate
    docker image prune
}


function copydir {
  pwd | tr -d "\r\n" | xclip
}

function url_redirect() {
    local URL=$1
    local REDIRECTS=0

    while true; do
        local OUTPUT=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" "$URL")
        local HTTP_CODE=$(echo "$OUTPUT" | cut -d' ' -f1)
        local NEW_URL=$(echo "$OUTPUT" | cut -d' ' -f2)

        if [[ "$HTTP_CODE" == "301" ]] || [[ "$HTTP_CODE" == "302" ]] || [[ "$HTTP_CODE" == "303" ]] || [[ "$HTTP_CODE" == "307" ]] || [[ "$HTTP_CODE" == "308" ]]; then
            echo "$URL -> $NEW_URL"
            URL=$NEW_URL
            REDIRECTS=$((REDIRECTS + 1))
        else
            echo "Final URL: $URL"
            echo "Total redirects: $REDIRECTS"
            break
        fi
    done
}

