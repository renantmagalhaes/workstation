
#!/bin/sh
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

#Install the packages from debian repo
apt-get install dconf-cli fonts-powerline curl

#Add Gogh
##Elementary
runuser -l $user -c 'wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt'
## Grubvbox dark
runuser -l $user -c 'wget -O xt https://git.io/v7eBS && chmod +x xt && ./xt && rm xt'

#Install fish
wget -nv https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key -O Release.key
apt-key add - < Release.key
apt-get update
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_9.0/ /' > /etc/apt/sources.list.d/fish.list
apt-get update
apt-get -y install fish

#Include Fish as user default shell
usermod -s /usr/bin/fish $user

runuser -l $user -c 'touch ~/.config/fish/config.fish'

cat <<EOF >> /home/$user/.config/fish/config.fish
set -g theme_display_git yes
set -g theme_display_git_untracked yes
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



#Add Fisherman
runuser -l $user -c 'curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher'

#Add Fisherman packages
runuser -l $user -c 'fisher install edc/bass'
runuser -l $user -c 'fisher install laughedelic/pisces'
runuser -l $user -c 'fisher install z'
runuser -l $user -c 'fisher install omf/theme-bobthefish'
