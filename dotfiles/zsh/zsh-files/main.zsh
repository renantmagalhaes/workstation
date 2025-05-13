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

# =====================
# fzf-tab config
# =====================
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' prefix '·'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# =====================
# General tweaks
# =====================
unset MAILCHECK
export TMUX_TMPDIR='/tmp'

# =====================
# Add paths depending on OS
# =====================
if [[ $os_check == "darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/opt/homebrew/bin"
elif [[ $os_check == "linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export PATH="$HOME/.local/bin:/usr/sbin:/usr/share/code/bin:$HOME/.cargo/bin:$HOME/.local/share/nvim/mason/bin:$PATH"
else
  echo "⚠️ OS check failed"
fi
# # =====================
# # NIX load
# # =====================
# if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
#
