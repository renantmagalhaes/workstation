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

# Wipes all history, rebuilding only the repo's default branch
git_nuke_history() {
  echo "⚠️  THIS WILL IRREVERSIBLY DELETE your .git folder and all history."
  echo "Type RESET to continue:"
  read -r CONFIRM
  if [[ "$CONFIRM" != "RESET" ]]; then
    echo "Aborted: did not type RESET."
    return 1
  fi

  # ensure we’re in a Git repo and go to its root
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "✖ Not inside a Git repo."
    return 1
  }
  cd "$root" || return 1

  # grab remote URL
  local origin_url
  origin_url=$(git config --get remote.origin.url)
  if [[ -z "$origin_url" ]]; then
    echo "✖ No 'origin' remote found. Aborting."
    return 1
  fi

  # detect default branch from origin HEAD
  local default_branch
  default_branch=$(git remote show origin \
    | sed -n 's/.*HEAD branch: //p')
  # fall back if detection fails
  if [[ -z "$default_branch" ]]; then
    default_branch="main"
    echo "→ Could not detect default; assuming 'main'."
  else
    echo "→ Detected default branch: '$default_branch'."
  fi

  local msg="${1:-Initial commit}"

  echo "→ Deleting old .git directory…"
  rm -rf .git

  echo "→ Re-initializing repo…"
  # for older Git, you may need to do 'git init' then 'git checkout -b'
  git init --initial-branch="$default_branch"
  git remote add origin "$origin_url"

  echo "→ Creating and committing on '$default_branch'…"
  git add -A
  git commit -m "$msg"

  echo "→ Force-pushing '$default_branch' and setting upstream…"
  if ! git push -u -f origin "$default_branch"; then
    echo "✖ Failed to push $default_branch. Check your credentials or remote URL."
    return 1
  fi

  # determine the other branch name to delete on remote
  local other_branch
  if [[ "$default_branch" = "main" ]]; then
    other_branch="master"
  else
    other_branch="main"
  fi

  echo "→ Deleting remote '$other_branch' (if it exists)…"
  git push origin --delete "$other_branch" 2>/dev/null || true

  echo "→ Running final garbage-collection…"
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now --aggressive

  echo "🎉 Done! Only '$default_branch' exists locally and on origin."
}
# Ensure noglob is applied *before* Zsh expands arguments
# Force Zsh to disable globbing before anything reaches _scp
alias scp='noglob _scp'

# Smart SCP wrapper
alias scp='noglob _scp'

_scp() {
  for arg in "$@"; do
    if [[ "$arg" == *:* && "$arg" == *[\~\*]* ]]; then
      echo "⚠️  Warning: Remote path '$arg' contains unquoted '~' or '*'"
      echo "👉  Use quotes like: scp 'user@host:~/path/*' ."
      break
    fi
  done

  command scp "$@"
}
# # Smart CP function
# alias cp='noglob _cp'

# _cp() {
#   for arg in "$@"; do
#     if [[ "$arg" == *[\~\*]* ]]; then
#       echo "⚠️  Warning: Argument '$arg' contains unquoted '~' or '*'"
#       echo "👉  Use quotes like: cp '~/folder/*' ./backup/"
#       break
#     fi
#   done

#   command cp "$@"
# }
