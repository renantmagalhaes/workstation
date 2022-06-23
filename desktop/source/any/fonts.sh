# Install Fonts
git clone https://github.com/powerline/fonts.git ~/GIT-REPOS/CORE/fonts/
bash ~/GIT-REPOS/CORE/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git ~/GIT-REPOS/CORE/awesome-terminal-fonts
sh -c "~/GIT-REPOS/CORE/awesome-terminal-fonts/install.sh"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/FiraCode.zip -O ~/.local/share/fonts/FiraCode.zip
unzip ~/.local/share/fonts/FiraCode.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/3270.zip -O ~/.local/share/fonts/3270.zip
unzip ~/.local/share/fonts/3270.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/Agave.zip -O ~/.local/share/fonts/Agave.zip
unzip ~/.local/share/fonts/Agave.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Iosevka.zip -O ~/.local/share/fonts/Iosevka.zip -O ~/.local/share/fonts/Iosevka.zip
unzip ~/.local/share/fonts/Iosevka.zip -d ~/.local/share/fonts/

## cascadia font for vscode
wget https://github.com/microsoft/cascadia-code/releases/download/v2105.24/CascadiaCode-2105.24.zip -O /tmp/CascadiaCode-2105.24.zip
unzip /tmp/CascadiaCode-2105.24.zip -d /tmp/
cp /tmp/ttf/CascadiaCodePL.ttf  ~/.local/share/fonts/
cp /tmp/ttf/CascadiaCode.ttf  ~/.local/share/fonts/

## jetbrains
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

# droid sans
wget https://www.fontsquirrel.com/fonts/download/droid-sans -O ~/.local/share/fonts/droid-sans.zip
unzip ~/.local/share/fonts/droid-sans.zip -d ~/.local/share/fonts/

fc-cache -vf ~/.local/share/fonts/
