#verify zsh
type zsh >/dev/null 2>&1 || { echo >&2 "Install zsh before run this script "; exit 1; }

#verify curl
type curl >/dev/null 2>&1 || { echo >&2 "Install zsh before run this script "; exit 1; }

#install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#zsh config 
ln -s -f $PWD/zsh/zshrc ~/.zshrc

#p10k config 
ln -s -f $PWD/zsh/p10k.zsh ~/.p10k.zsh

#lsd config
mkdir -p  ~/.config/lsd/
ln -s -f $PWD/lsd-config.yaml ~/.config/lsd/config.yaml

#install plugins
##zsh-syntax-highlighting.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
##zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
##zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
autoload -U compinit && compinit
## enhancd
git clone https://github.com/b4b4r07/enhancd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd
sed -i 's/\.\./\./g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh
sed -i 's/ENHANCD_DISABLE_HYPHEN\:\-0/ENHANCD_DISABLE_HYPHEN\:\-1/g' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/enhancd/init.sh

#install powerlevel9k
#git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


#set zsh as default shell
clear
echo "To set zsh as default shell run sudo chsh -s $(which zsh)"
