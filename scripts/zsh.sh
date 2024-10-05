# Get current folder
FOLDER_LOCATION=$(pwd)

#verify zsh
type zsh >/dev/null 2>&1 || {
	echo >&2 "Install zsh before run this script "
	exit 1
}

#verify curl
type curl >/dev/null 2>&1 || {
	echo >&2 "Install zsh before run this script "
	exit 1
}

macos_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')
linux_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')

#install oh-my-zsh
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /tmp/zsh.sh
sed -i 's/exec\ zsh\ \-l//g' /tmp/zsh.sh
chmod +x /tmp/zsh.sh
sh -c '/tmp/zsh.sh'

# Install startship
#curl -sS https://starship.rs/install.sh | sh

#zsh config
ln -s -f $PWD/dotfiles/zsh/zshrc ~/.zshrc
ln -s -f $PWD/dotfiles/zsh/zsh-files ~/.zsh

#p10k config
ln -s -f $PWD/dotfiles/zsh/p10k.zsh ~/.p10k.zsh

#lsd config
mkdir -p ~/.config/lsd/
ln -s -f $PWD/dotfiles/zsh/lsd-config.yaml ~/.config/lsd/config.yaml
ln -s -f $PWD/dotfiles/zsh/colors.yaml ~/.config/lsd/colors.yaml

#install plugins
##zsh-syntax-highlighting.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

##zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

##zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

##zsh-autopair
git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autopair

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

#install powerlevel9k
#git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

#fix fzf
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin/
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

#set zsh as default shell
echo "To set zsh as default shell run sudo chsh -s $(which zsh)"

# Return original path
cd $FOLDER_LOCATION
