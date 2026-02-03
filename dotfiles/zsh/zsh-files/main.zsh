# =====================
# Check if command exists
# =====================
check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# =====================
# OS Detection
# =====================
os_check=$(uname -s | tr '[:upper:]' '[:lower:]')

# =====================
# Oh My Zsh Plugins
# =====================
plugins=(
  git
  kubectl
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  colorize
  command-not-found
  docker
  docker-compose
  tmux
  virtualenv
  git-auto-fetch
  aws
  sudo
  copyfile
  copybuffer
  copypath
  systemadmin
  rsync
  fzf
  fzf-tab
)

# =====================
# Custom Plugins
# =====================
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# zsh-autopair (not part of OMZ)
if [[ -r $ZSH_CUSTOM/plugins/zsh-autopair/autopair.zsh ]]; then
  source $ZSH_CUSTOM/plugins/zsh-autopair/autopair.zsh
fi

# fzf integration (optional)
check_cmd fzf && source <(fzf --zsh)

# =====================
# Python virtualenv
# =====================
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"

# =====================
# Git Auto Fetch
# =====================
GIT_AUTO_FETCH_INTERVAL=10

# =====================
# History settings
# =====================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# =====================
# WSL2 RAM cleanup alias
# =====================
alias drop_cache="sudo sh -c \"echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && echo 'Ram-cache and Swap Cleared'\""

# =====================
# Use best available top
# =====================
if check_cmd bpytop; then
  alias top='bpytop'
elif check_cmd htop; then
  alias top='htop'
fi

# =====================
# Completion system with cache
# =====================
ZSH_CACHE_DIR="${ZDOTDIR:-$HOME}/.zsh_cache"
mkdir -p "$ZSH_CACHE_DIR"

autoload -Uz compinit
compinit -d "${ZSH_CACHE_DIR}/zcompdump"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/zcache"

autoload -U +X bashcompinit && bashcompinit

# ==========================================
# fzf-tab config (Reliable Full-Width Layout)
# ==========================================

# We DO NOT set 'fzf-command'. This forces fzf-tab to use its default, stable layout.
#zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Set the preview command for the 'cd' completion.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -a --tree --depth=1 $realpath || ls -la $realpath'

# --- Your other working settings ---
zstyle ':fzf-tab:*' prefix '·'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
# =====================
# General tweaks
# =====================
unset MAILCHECK
export TMUX_TMPDIR='/tmp'

# =====================
# Add paths depending on OS
# =====================

# --- Helper: robust WSL detection (WSL1 + WSL2, future-proof) ---
is_wsl() {
  # Primary: kernel release contains WSL
  grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null && return 0

  # Secondary: official WSL environment variable
  [ -n "$WSL_DISTRO_NAME" ] && return 0

  # Fallback: Windows mount point exists
  [ -d /mnt/c ] && return 0

  return 1
}

# --- Helper: resolve Windows HOME directory safely (WSL only) ---
get_win_home() {
  local win_home
  win_home="$(cmd.exe /c echo %USERPROFILE% 2>/dev/null | tr -d '\r')"
  wslpath "$win_home"
}

if [[ $os_check == "darwin" ]]; then
  # -----------------
  # macOS
  # -----------------
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/opt/homebrew/bin"

elif [[ $os_check == "linux" ]]; then
  # -----------------
  # Linux (base)
  # -----------------
  export PATH="$HOME/.local/bin:/usr/sbin:/usr/share/code/bin:$HOME/.cargo/bin:$HOME/.local/share/nvim/mason/bin:$PATH"

  # Linuxbrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # -----------------
  # WSL-specific logic
  # -----------------
  if is_wsl; then
    # Core Windows system paths (read-only, safe)
    export PATH="$PATH:/mnt/c/Windows:/mnt/c/Windows/System32"

    # Resolve Windows home dynamically (Linux user ≠ Windows user safe)
    WIN_HOME="$(get_win_home)"

    # Windows App Execution Aliases (user-writable → keep LAST)
    export PATH="$PATH:$WIN_HOME/AppData/Local/Microsoft/WindowsApps:$WIN_HOME/AppData/Local/Microsoft/WinGet/Links"

    # -----------------
    # Explicit aliases (SECURITY-FIRST)
    # -----------------

    code() {
      local bin="$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin/code"
      if [ -x "$bin" ]; then
        "$bin" "$@"
      else
        echo "❌ VS Code not found at expected location" >&2
        return 127
      fi
    }

    cursor() {
      local bin="$WIN_HOME/AppData/Local/Programs/cursor/resources/app/bin/cursor"
      if [ -x "$bin" ]; then
        "$bin" "$@"
      else
        echo "❌ Cursor not found at expected location" >&2
        return 127
      fi
    }


  fi

else
  echo "⚠️ OS check failed"
fi

# =====================

# Prefer system tools
export PATH="/usr/bin:/bin:$PATH"


# # =====================
# # NIX load
# # =====================
# if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
#
