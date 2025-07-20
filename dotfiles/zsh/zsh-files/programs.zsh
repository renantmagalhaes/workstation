# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`
linux_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`

# FZF color scheme
## with transparent
#export FZF_DEFAULT_OPTS='--height 40% --inline-info --border --color=fg:#f8f8f2,hl:#88f298 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#88f298 --color=info:#f0fc68,prompt:#7499f7,pointer:#ffb86c --color=marker:#ffb86c,spinner:#9cf598,header:#6272a4'
export FZF_DEFAULT_OPTS='--height 50% --inline-info --border --color=fg:#f8f8f2,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#9cf598,prompt:#7499f7,pointer:#ffb86c --color=marker:#ffb86c,spinner:#9cf598,header:#6272a4'
## with opaque bg
#export FZF_DEFAULT_OPTS='--height 40% --inline-info --border --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
#export FZF_DEFAULT_OPTS='--color=fg:#ebfafa,bg:#282a36,hl:#37f499 --color=fg+:#ebfafa,bg+:#212337,hl+:#37f499 --color=info:#f7c67f,prompt:#04d1f9,pointer:#7081d0 --color=marker:#7081d0,spinner:#f7c67f,header:#323449'

#NIX
export NIXPKGS_ALLOW_UNFREE=1

## enhancd
#source $ZSH/custom/plugins/enhancd/init.sh
##ENHANCD_FILTER=fzf --height 40%:fzy
#export ENHANCD_FILTER

# command -v exa > /dev/null && alias ls='exa --icons --group-directories-first -g -b -h' && \
#alias tree='exa --tree'
command -v lsd > /dev/null && \
alias ls='lsd --group-dirs first' && \
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
