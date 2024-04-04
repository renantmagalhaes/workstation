# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`
linux_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`


# #Plugins

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



# ######################### General Setup ########################

#Custom plugins
##zsh-syntax-highlighting
if [[ ! -d $ZSH/custom/plugins/zsh-syntax-highlighting ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH/custom/plugins/zsh-syntax-highlighting
fi
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

##zsh-autosuggestions.zsh
if [[ ! -d $ZSH/custom/plugins/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
fi
source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


##Autopair
if [[ ! -d $ZSH/custom/plugins/zsh-autopair ]]; then
  git clone https://github.com/hlissner/zsh-autopair $ZSH/custom/plugins/zsh-autopair
fi
source $ZSH/custom/plugins/zsh-autopair/autopair.zsh

## FZF
source ~/.fzf.zsh

# Python virtualenv and Virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3

# git-auto-fetch
GIT_AUTO_FETCH_INTERVAL=60

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
# For tmux 
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' prefix '·'
## disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
## set descriptions format to enable group support
## NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
## set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
## force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
## preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
## switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':completion:*:descriptions' format

# Additional paths
if [[ $macos_check == "darwin" ]]; then
    eval $(/usr/local/bin/brew shellenv)
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
elif [[ $linux_check == "linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export PATH="$HOME/.local/bin:/usr/sbin:/usr/share/code/bin:$HOME/.cargo/bin/:$PATH"
else
    echo "error on SO check"
fi
