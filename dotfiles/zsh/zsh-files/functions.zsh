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
git-nuke-history() {
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

# ==============================================================================
#
# git_optimize_repo
#
# A comprehensive, interactive Zsh function to clean, optimize, and diagnose
# the local Git repository.
#
# USAGE:
#   1. Add this function to your Zsh configuration (e.g., ~/.zsh/functions.zsh).
#   2. Source the file in your .zshrc: `source ~/.zsh/functions.zsh`
#   3. Restart your shell or run `source ~/.zshrc`.
#   4. Navigate to a Git repository and run the command: `git_optimize_repo`
#
# ==============================================================================
git-optimize-repo() {
  # --- Safety Check: Ensure we are in a Git repository ---
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "\e[31mError: Not inside a Git repository.\e[0m"
    return 1
  fi

  # --- Helper function for user confirmation ---
  _ask_for_confirmation() {
    local prompt="$1"
    while true; do
      read -q "REPLY?$prompt (y/n): "
      echo # Move to the next line after user input
      case "$REPLY" in
        [Yy]) return 0 ;; # Success (yes)
        [Nn]) return 1 ;; # Failure (no)
        *) echo "\e[33mPlease answer y or n.\e[0m" ;;
      esac
    done
  }

  # --- Start of Optimization Steps ---
  echo "\e[1;36mStarting Git Repository Optimization...\e[0m"
  echo "You will be prompted to confirm each step."
  echo "---------------------------------------------------"


  # --- Step 1: Clean Untracked Files ---
  echo "\n\e[1;34mStep 1: Clean untracked files with 'git clean'\e[0m"
  echo "\e[39mThis step removes files and directories that are not tracked by Git.\e[0m"
  echo "\e[33mWarning: This is useful for removing build artifacts or logs, but it is a destructive operation. A backup is always a good idea.\e[0m\n"

  # Perform a dry run first to show what would be deleted.
  local untracked_files
  untracked_files=$(git clean -ndx)

  if [[ -z "$untracked_files" ]]; then
    echo "\e[32m✔ No untracked files to clean.\e[0m"
  else
    echo "The following files and directories would be DELETED:"
    echo "\e[33m$untracked_files\e[0m"
    if _ask_for_confirmation "Do you want to permanently delete these files?"; then
      echo "Cleaning repository..."
      git clean -fdx
      echo "\e[32m✔ Untracked files have been deleted.\e[0m"
    else
      echo "\e[37mSkipped cleaning untracked files.\e[0m"
    fi
  fi
  echo "---------------------------------------------------"


  # --- Step 2: Garbage Collection ---
  echo "\n\e[1;34mStep 2: Run Garbage Collection with 'git gc'\e[0m"
  echo "\e[39mThis command optimizes the repository's internal structure. It cleans up unnecessary files, compresses file revisions, and improves performance.\e[0m\n"

  if _ask_for_confirmation "Do you want to run garbage collection?"; then
    echo "Running aggressive garbage collection..."
    git gc --prune=now --aggressive
    echo "\e[32m✔ Repository garbage collection complete.\e[0m"
  else
    echo "\e[37mSkipped garbage collection.\e[0m"
  fi
  echo "---------------------------------------------------"


  # --- Step 3: Repack Objects ---
  echo "\n\e[1;34mStep 3: Repack loose objects with 'git repack'\e[0m"
  echo "\e[39mThis command combines many small Git objects into fewer, larger 'packfiles'. This can significantly speed up operations in repositories with a long history.\e[0m\n"

  if _ask_for_confirmation "Do you want to repack repository objects?"; then
    echo "Repacking objects..."
    # -a: pack all reachable objects
    # -d: delete redundant loose objects after packing
    git repack -ad
    echo "\e[32m✔ Repository objects have been repacked.\e[0m"
  else
    echo "\e[37mSkipped repacking.\e[0m"
  fi
  echo "---------------------------------------------------"


  # --- Step 4: Check for Large Files (Informational) ---
  echo "\n\e[1;34mStep 4: Identify large files in history (Informational)\e[0m"
  echo "\e[39mThis will scan the entire repository history to find the 10 largest files ever committed. This does NOT delete anything.\e[0m"
  echo "\e[33mNote: If your repo is slow due to large binary files, you may need advanced tools like 'git filter-repo' to remove them from history.\e[0m\n"

  if _ask_for_confirmation "Do you want to check for large files?"; then
    echo "Searching for the 10 largest objects in history..."
    # This command chain finds all objects, gets their sizes, sorts them, and shows the top 10.
    git rev-list --objects --all | \
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
    sed -n 's/^blob //p' | \
    sort --numeric-sort --key=2 | \
    tail -n 10 | \
    awk '{
      size=$2/1024;
      if (size > 1024) {
        printf "%.2f MB\t%s\n", size/1024, $3
      } else {
        printf "%.2f KB\t%s\n", size, $3
      }
    }'
    echo "\e[32m✔ Large file check complete.\e[0m"
  else
    echo "\e[37mSkipped large file check.\e[0m"
  fi
  echo "---------------------------------------------------"


  # --- Step 5: Display Repository Statistics (Informational) ---
  echo "\n\e[1;34mStep 5: Display repository statistics with 'git count-objects'\e[0m"
  echo "\e[39mThis provides a 'health report' of the repository, showing the number of objects and the disk space they consume.\e[0m\n"

  if _ask_for_confirmation "Do you want to display the repository health report?"; then
    git count-objects -vH
    echo "\e[32m✔ Health report complete.\e[0m"
  else
    echo "\e[37mSkipped health report.\e[0m"
  fi
  echo "---------------------------------------------------"

  echo "\n\e[1;32mOptimization and analysis process finished!\e[0m"
}

# Ensure noglob is applied *before* Zsh expands arguments
# Force Zsh to disable globbing before anything reaches _scp
# alias scp='noglob _scp'

# Smart SCP wrapper
# alias scp='noglob _scp'

# _scp() {
#   for arg in "$@"; do
#     if [[ "$arg" == *:* && "$arg" == *[\~\*]* ]]; then
#       echo "⚠️  Warning: Remote path '$arg' contains unquoted '~' or '*'"
#       echo "👉  Use quotes like: scp 'user@host:~/path/*' ."
#       break
#     fi
#   done
#
#   command scp "$@"
# }
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
# A multi-purpose cd command with a powerful fzf-based menu.
# This definitive version automatically includes subdirectories from your zoxide history,
# AND allows for a deep filesystem search with Ctrl+F.
# A multi-purpose cd command with a powerful fzf-based menu.
cd() {
    # --- Case 1: `cd .` to interactively climb up the directory tree ---
    if [[ "$1" == "." ]]; then
        local up_target_dir
        up_target_dir=$(
            local current_path="$PWD"
            local parent_path
            while [ "$current_path" != "/" ]; do
                parent_path=$(dirname "$current_path")
                echo "$parent_path"
                current_path="$parent_path"
            done | fzf --height 25% --reverse --header "Jump up to which parent directory?"
        )
        if [[ -n "$up_target_dir" ]]; then
            builtin cd "$up_target_dir"
        fi
        return
    fi

    # --- Case 2: `cd -` to show a list of the last 5 chronological directories ---
    if [[ "$1" == "-" ]]; then
        local recent_target_dir
        # Use `dirs -pl` to print full, absolute paths and avoid tilde expansion errors.
        recent_target_dir=$(
            dirs -pl | tail -n +2 | head -n 5 | fzf --height 25% --reverse --header "Recent Directories (Chronological)"
        )
        if [[ -n "$recent_target_dir" ]]; then
            builtin cd "$recent_target_dir"
        fi
        return
    fi

    # --- Case 3: Standard cd behavior for any existing directory ---
    if [ -d "$1" ]; then
        builtin cd "$1"
        return
    fi

    # --- Case 4: The main interactive fzf menu ---
    local target_dir
    target_dir=$(
        (
            zoxide query -l;
            zoxide query -l | xargs -I {} fd --max-depth 1 --type d . "{}"
        ) | awk '!seen[$0]++ && $0' | fzf --height 50% --reverse \
            --query="$@" \
            --header "SMART LIST (Ctrl+F for deep search)" \
            --preview 'lsd -a --tree --depth=1 {} || exa -a --tree --level=2 {} || ls -la {}' \
            --bind "ctrl-f:reload(fd --type d --hidden . \"$HOME\" \
                --exclude /home/rtm/Data \
            )+change-header(FULL FILESYSTEM SEARCH)"
    )
    if [[ -n "$target_dir" ]]; then
        builtin cd "$target_dir"
    fi
}

# Function to safely clean the zoxide database with confirmation.
# This version uses the most robust, basic form of `read` to avoid shell issues.
zoxide_cd_clean() {
    local zoxide_db_path="$HOME/.local/share/zoxide/db.zo"

    # First, check if there is even a database to delete.
    if [[ ! -f "$zoxide_db_path" ]]; then
        echo "Zoxide database already clean (file not found)."
        return
    fi

    # Ask for user confirmation using the most compatible method.
    # 1. Print the prompt without a newline using 'echo -n'.
    echo -n "Are you sure you want to permanently delete the zoxide database? [y/N] "
    # 2. Read the user's input into the REPLY variable.
    read REPLY

    # Check the user's reply.
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        # If 'y' or 'Y' was pressed, remove the file.
        rm "$zoxide_db_path"
        echo "✅ Zoxide database has been reset. It will be rebuilt as you navigate."
    else
        # If any other key was pressed (including just Enter), abort.
        echo "🚫 Clean operation aborted."
    fi
}

# WireGuard connect/disconnect helper
vpn() {
  local confpath confname

  # Optional second arg lets you choose a config by name, e.g. `vpn c mainframe28`
  if [[ -n "$2" ]]; then
    confname="${2%.conf}"
  else
    # Find the first .conf as root to avoid zsh glob errors
    confpath=$(sudo sh -c 'ls -1 /etc/wireguard/*.conf 2>/dev/null | head -n1')
    if [[ -z "$confpath" ]]; then
      echo "No WireGuard config found in /etc/wireguard"
      return 1
    fi
    confname="${confpath##*/}"
    confname="${confname%.conf}"
  fi

  case "$1" in
    c)
      echo "Connecting to $confname..."
      sudo wg-quick up "$confname"
      ;;
    d)
      echo "Disconnecting from $confname..."
      sudo wg-quick down "$confname"
      ;;
    s)
      # status helper
      sudo wg show
      ;;
    *)
      echo "Usage: vpn c|d|s [config_name_without_.conf]"
      ;;
  esac
}

# Generate a secure, web-compatible, shell-safe password
# Usage: genpass [length] [count] (Defaults to 20 1)
genpass() {
  local len=${1:-20}
  local count=${2:-1}
  pwgen -s -y -c -n -B -1 "$len" "$count" -r "\`~[](){}:;<>^\\|'\",./?*$"
}

alias passgen='genpass'
alias password_generator='genpass'
alias pwgen_rtm='genpass'

# Generate a random number
# Usage: genum [max] OR genum [min] [max]
random_number() {
  if [ $# -eq 0 ]; then
    # Default: random number between 1 and 100
    echo $(( RANDOM % 100 + 1 ))
  elif [ $# -eq 1 ]; then
    # Range: 1 to [max]
    echo $(( RANDOM % $1 + 1 ))
  else
    # Range: [min] to [max]
    echo $(( RANDOM % ($2 - $1 + 1) + $1 ))
  fi
}
