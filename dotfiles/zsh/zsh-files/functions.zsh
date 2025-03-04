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

function find-folder-root () {
sudo find $1 -type d -iname $2 -exec bat {} +
}

function find-file () {
find $1 -type f -iname $2 -exec bat {} +
}

function find-file-root () {
sudo find $1 -type f -iname $2 -exec bat {} +
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

## Copy direcory to clipboard
function copydir {
  pwd | tr -d "\r\n" | xclip
}

## Check the number of redirects a URL have
function url-redirect() {
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

## Launch Strem.IO companion app for web
function stremio-web-companion-app(){
    # Check if ffmpeg is installed
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "ffmpeg not found."
        return 1
    fi

    # Check if docker is installed
    if ! command -v docker >/dev/null 2>&1; then
        echo "docker not found."
        return 1
    fi

    # Run the Docker command
    docker run --rm -d --name stremio-web -p 11470:11470 -p 12470:12470 stremio/server:latest
}


# Function to generate a random MAC address
random_mac() {
  local separator="${1:-:}"  # Default separator is ':'
  
  if [[ "$separator" != ":" && "$separator" != "-" ]]; then
    echo "Invalid separator. Use ':' or '-'."
    return 1
  fi

  # Generate a MAC address
  printf "%02X${separator}%02X${separator}%02X${separator}%02X${separator}%02X${separator}%02X\n" \
    $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) \
    $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256))
}

# Generates a random SMBIOS UUID
function random_smbios() {
  # Use openssl to get 16 random bytes as a hex string (32 hex characters total)
  local random_hex=$(openssl rand -hex 16)
  
  # Split into 5 parts: 8-4-4-4-12
  local part1=${random_hex:0:8}
  local part2=${random_hex:8:4}
  local part3=${random_hex:12:4}
  local part4=${random_hex:16:4}
  local part5=${random_hex:20:12}
  
  # Print in SMBIOS (UUIDv4) format
  echo "${part1}-${part2}-${part3}-${part4}-${part5}"
}

# VI erase config
function vim-delete-config() {
  echo "This will delete the following directories:"
  echo "  - ~/.local/share/nvim"
  echo "  - ~/.local/state/nvim"
  echo "  - ~/.cache/nvim"
  echo
  echo "Type 'DELETE' to confirm:"
  read -r user_input

  if [[ $user_input == "DELETE" ]]; then
    rm -rf ~/.local/share/nvim \
           ~/.local/state/nvim \
           ~/.cache/nvim
    echo "Neovim directories removed."
  else
    echo "Operation canceled."
  fi
}
