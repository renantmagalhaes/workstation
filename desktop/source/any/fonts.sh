# Install Fonts
git clone https://github.com/powerline/fonts.git ~/GIT-REPOS/CORE/fonts/
bash ~/GIT-REPOS/CORE/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git ~/GIT-REPOS/CORE/awesome-terminal-fonts
sh -c "~/GIT-REPOS/CORE/awesome-terminal-fonts/install.sh"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/FiraCode.zip -O ~/.local/share/fonts/FiraCode.zip
unzip -o ~/.local/share/fonts/FiraCode.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/JetBrainsMono.zip -O ~/.local/share/fonts/JetBrainsMono.zip
unzip -o ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/`curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/CascadiaCode.zip -O ~/.local/share/fonts/CascadiaCode.zip
unzip -o ~/.local/share/fonts/CascadiaCode.zip -d ~/.local/share/fonts/

## cascadia font for vscode
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -O /tmp/CascadiaCode.zip
unzip -o /tmp/CascadiaCode.zip -d /tmp/
cp /tmp/ttf/CascadiaCodePL.ttf  ~/.local/share/fonts/
cp /tmp/ttf/CascadiaCode.ttf  ~/.local/share/fonts/

# fonts aawesome
wget https://github.com/FortAwesome/Font-Awesome/releases/download/`curl --silent "https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`/fontawesome-free-`curl --silent "https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest" |grep tag_name |awk '{print $2}' |sed 's/\"//g; s/\,//g'`-desktop.zip -O ~/.local/share/fonts/Font-Awesome.zip
unzip -o ~/.local/share/fonts/Font-Awesome.zip -d ~/.local/share/fonts/

# Fonts for rofi menu
wget https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/GrapeNuts-Regular.ttf -O ~/.local/share/fonts/GrapeNuts-Regular.ttf
wget https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/Icomoon-Feather.ttf -O ~/.local/share/fonts/Icomoon-Feather.ttf
# wget https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/Iosevka-Nerd-Font-Complete.ttf ~/.local/share/fonts/
# wget https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/JetBrains-Mono-Nerd-Font-Complete.ttf ~/.local/share/fonts/

#SFMono-Nerd-Font-Ligaturized
git clone https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono-Nerd-Font-Ligaturized
cp /tmp/SFMono-Nerd-Font-Ligaturized/*.otf ~/.local/share/fonts

#SFMono-Nerd-Font
git clone https://github.com/securitybydesign/SF-Mono-Nerd-Font.git /tmp/SFMono-Nerd-Font
cp /tmp/SFMono-Nerd-Font/*.otf ~/.local/share/fonts


fc-cache -vf ~/.local/share/fonts/
