# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`
linux_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`



plugins=(
  git
  kubectl
  #kube-ps1
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

#Custom plugins
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#Python virtualenv and Virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3

# FZF color scheme
## with transparent
#export FZF_DEFAULT_OPTS='--height 40% --inline-info --border --color=fg:#f8f8f2,hl:#88f298 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#88f298 --color=info:#f0fc68,prompt:#7499f7,pointer:#ffb86c --color=marker:#ffb86c,spinner:#9cf598,header:#6272a4'
export FZF_DEFAULT_OPTS='--height 50% --inline-info --border --color=fg:#f8f8f2,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#9cf598,prompt:#7499f7,pointer:#ffb86c --color=marker:#ffb86c,spinner:#9cf598,header:#6272a4'
## with opaque bg
#export FZF_DEFAULT_OPTS='--height 40% --inline-info --border --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# History 
HISTFILE="$HOME/.zsh_history"
## Number of events loaded into memory
HISTSIZE=1000000
## Number of events stored in the zsh history file
SAVEHIST=1000000
## Do not save duplicate commands to history
setopt HIST_IGNORE_ALL_DUPS
## Do not find duplicate command when searching
setopt HIST_FIND_NO_DUPS

# suse tmux fix
export TMUX_TMPDIR='/tmp'

# This is specific to WSL 2. If the WSL 2 VM goes rogue and decides not to free
# up memory, this command will free your memory after about 20-30 seconds.
#   Details: https://github.com/microsoft/WSL/issues/4166#issuecomment-628493643
alias drop_cache="sudo sh -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\""

# command -v exa > /dev/null && alias ls='exa --icons --group-directories-first -g -b -h' && \
#   alias tree='exa --tree'
command -v lsd > /dev/null && alias ls='lsd --group-dirs first' && \
	alias tree='lsd --tree'


### CAT & LESS ###
command -v bat > /dev/null && \
	alias bat='bat --style=plain --theme=OneHalfDark' && \
	alias cat='bat --pager=never' && \
	alias less='bat' && \
    alias tailf="tail -f $1 | bat --paging=never -l log" && \
    function gitd() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
    }

# colorize ls
[ -x /usr/bin/dircolors ] && eval "$(dircolors -b)"

### TOP ###
command -v htop > /dev/null && alias top='htop'
command -v bpytop > /dev/null && alias top='bpytop'

# Completion.
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'


# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zcache

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit


# fzf-tab
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' prefix '·'
zstyle ':completion:*:descriptions' format

# enhancd
source "$ZSH/custom/plugins/enhancd/init.sh"
ENHANCD_FILTER=fzf
export ENHANCD_FILTER