#!/bin/sh
#
# installer_workstation.sh - Script to install my full workstation experience
#
#Site       :http://renantmagalhaes.com
#Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#                                     <https://github.com/renantmagalhaes>
#
# ---------------------------------------------------------------
#
#  When executing the script it will make all the changes in the system and will download / install the most used packages.
#
#
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2017-12-02 RTM:
#       - Initial release
#
#   V0.2 2017-12-03 RTM:
#       - added more packages from debian repo
#
#   V0.2.1 2017-12-03 RTM:
#       - Sintax adjustments
#       - Add github address in header
#       - Enable blowfish2 vim cryptmethod
#
#   V0.3 2017-12-11
#       - Added tmux plugin manager
#
#   V0.4 2017-12-29
#       - Rework Oh my fish! installation
#       - Auto install bobthefish
#
#   TODO

#  Install advanced tmux config
#  sed the config to user powerline in tmux tmux_conf_theme_left_separator* tmux_conf_theme_right_separator
#  Add more bindn keys to tmux
#  Add virtualization software
#  Auto ctrl b + I to load tmux plugins
#  Install xmind / freemind
#  Install Draw.Io
#
#RTM

#Root check
if [ “$(id -u)” != “0” ]; then
echo “This script must be run as root” 2>&1
exit 1
fi

#User check
echo "#########################"
echo "#			#"
echo "#	User Config	#"
echo "#			#"
echo "#########################"

echo "Enter your default user name:"
read user

# source.list backup
cp /etc/apt/sources.list /etc/apt/sources.list.bkp

#Comment cdrom entry
sed -e '/deb cdrom:/ s/^#*/#/' -i /etc/apt/sources.list

#Add non-free packages
sed -e 's/main/main non-free/g' -i /etc/apt/sources.list

#Update / upgrade
apt-get update && apt-get upgrade

#Install the packages from debian repo
apt-get -y install clementine deluge dia vim vim-gtk vim-gui-common nmap vlc gimp blender fonts-powerline inkscape brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome x2goclient caja-share caja-open-terminal git gnome-icon-theme idle3 mate-sensors-applet guake guake-indicator numix-gtk-theme numix-icon-theme firmware-linux firmware-linux-nonfree firmware-linux-free fonts-hack-ttf apt-transport-https htop python3-pip meld

#Install Firefox pt-BR 57
wget https://ftp.mozilla.org/pub/firefox/releases/57.0.1/linux-x86_64/pt-BR/firefox-57.0.1.tar.bz2 -O /tmp/firefox-57.0.1.tar.bz2
tar -xvjf /tmp/firefox-57.0.1.tar.bz2 -C /usr/local
ln -s /usr/local/firefox/firefox /usr/bin/firefox-quantum
cat <<EOF > /usr/share/applications/firefox-quantum.desktop
[Desktop Entry]
Name=Firefox Quantum
Exec=/usr/local/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/usr/local/firefox/browser/icons/mozicon128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox-quantum
StartupNotify=true
EOF

#Install GTK theme
wget https://github.com/LinxGem33/OSX-Arc-Darker/releases/download/v1.4.5/osx-arc-collection_1.4.5_amd64.deb -O /tmp/osx-arc-collection_1.4.5_amd64.deb
dpkg -i /tmp/osx-arc-collection_1.4.5_amd64.deb

#Install Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt-get install sublime-text

#Install fish
wget -nv https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key -O Release.key
apt-key add - < Release.key
apt-get update
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_9.0/ /' > /etc/apt/sources.list.d/fish.list
apt-get update
apt-get -y install fish

#Include Fish as user default shell
echo 'fish' >> /home/$user/.bashrc

#Create vim config
#CREDITS to Amir <https://github.com/amix/vimrc>
runuser -l $user -c 'git clone https://github.com/amix/vimrc.git ~/.vim_runtime'
runuser -l $user -c 'bash ~/.vim_runtime/install_awesome_vimrc.sh'

cat <<EOF >> /home/$user/.vimrc
if ! has("gui_running")
    set t_Co=256
endif
" feel free to choose :set background=light for a different style
set background=dark
colors peaksea

set cm=blowfish2
EOF

cat <<EOF >> /home/$user/.gvimrc
if ! has("gui_running")
    set t_Co=256
endif
" feel free to choose :set background=light for a different style
set background=dark
colors peaksea

if has('gui_running')
  set guifont=Monospace\ 10
endif

set cm=blowfish2
EOF

#Set Oh My Fish
runuser -l $user -c 'curl -L https://get.oh-my.fish > install'
runuser -l $user -c 'fish install --path=~/.local/share/omf --config=~/.config/omf --noninteractive'
runuser -l $user -c 'touch ~/.config/fish/config.fish'

cat <<EOF >> /home/$user/.config/fish/config.fish
set -g theme_display_git no
set -g theme_display_git_untracked no
set -g theme_display_git_ahead_verbose yes
set -g theme_git_worktree_support yes
set -g theme_display_vagrant yes
set -g theme_display_docker_machine no
set -g theme_display_hg yes
set -g theme_display_virtualenv no
set -g theme_display_ruby no
set -g theme_display_user yes
set -g theme_display_vi no
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_title_display_process yes
set -g theme_title_display_path yes
set -g theme_title_use_abbreviated_path yes
set -g theme_date_format "+%a %H:%M"
set -g theme_avoid_ambiguous_glyphs yes
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
set -g default_user your_normal_user
set -g theme_color_scheme dark
set -g fish_prompt_pwd_dir_length 0
set -g theme_project_dir_length 1
EOF

#Install bobthefish
runuser -l $user -c "/usr/bin/fish -c 'omf install bobthefish'" 

#Set Tmux basic advanced config
#CREDITS to Gregory <https://github.com/gpakosz>
runuser -l $user -c 'cd /home/$user'
runuser -l $user -c 'git clone https://github.com/gpakosz/.tmux.git'
runuser -l $user -c 'ln -s -f .tmux/.tmux.conf'
runuser -l $user -c 'cp .tmux/.tmux.conf.local .'

echo 'export TERM="xterm-256color"' >> /home/$user/.bashrc
echo 'alias tmux="tmux -2"' >> /home/$user/.bashrc

#Install plugin manager for tmux
runuser -l $user -c 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
cat <<EOF >> /home/$user/.tmux.conf
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-capture-pane-contents 'on'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF



#RTM

echo "www.renantmagalhaes.com"
