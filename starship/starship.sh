#!/bin/bash
#verify zsh
type zsh >/dev/null 2>&1 || { echo >&2 "Install zsh before run this script "; exit 1; }

#verify curl
type curl >/dev/null 2>&1 || { echo >&2 "Install zsh before run this script "; exit 1; }

# Install starship
brew install starship

#install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Syslink for zshconfig
ln -s -f $PWD/zsh ~/.zsh

# Syslink for zshrc
ln -s -f $PWD/zshrc ~/.zshrc

# Syslink for startship
mkdir -p ~/.config/starship
ln -s -f $PWD/starship.toml ~/.config/starship/starship.toml

#lsd config
mkdir -p  ~/.config/lsd/
ln -s -f $PWD/zsh/lsd-config.yaml ~/.config/lsd/config.yaml

#install plugins
##zsh-syntax-highlighting.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

##zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

##zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
autoload -U compinit && compinit

## fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

## enhancd
git clone https://github.com/b4b4r07/enhancd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/
git checkout tags/v2.5.0
cd -

if [[ $macos_check == "darwin" ]]; then
    sed -i '' 's/\.\./\./g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh
    sed -i '' 's/ENHANCD_DISABLE_HYPHEN\:\-0/ENHANCD_DISABLE_HYPHEN\:\-1/g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh
elif [[ $linux_check == "linux" ]]; then
    sed -i 's/\.\./\./g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh
    sed -i 's/ENHANCD_DISABLE_HYPHEN\:\-0/ENHANCD_DISABLE_HYPHEN\:\-1/g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh
else
echo "Not able to identify desktop environment"
fi

#fix fzf
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install