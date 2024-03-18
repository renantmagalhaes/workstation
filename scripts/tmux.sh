#Based in Gregory's config <https://github.com/gpakosz>

#verify tmux
type tmux >/dev/null 2>&1 || {
	echo >&2 "Install tmux before run this script "
	exit 1
}

#install tmp (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#Create syslinks
ln -s -f $PWD/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s -f $PWD/dotfiles/tmux/tmux.conf.local ~/.tmux.conf.local

# Install plugins
bash -c "~/.tmux/plugins/tpm/scripts/install_plugins.sh"

# catppuccin setup
rm -rf ~/.tmux/plugins/tmux/custom
mkdir -p ~/.tmux/plugins/tmux/
ln -s -f $PWD/dotfiles/tmux/plugins/catppuccin/custom ~/.tmux/plugins/tmux/custom

