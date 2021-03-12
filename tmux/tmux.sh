#Based in Gregory's config <https://github.com/gpakosz> 

#verify tmux
type tmux >/dev/null 2>&1 || { echo >&2 "Install tmux before run this script "; exit 1; }

#install tmp (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


#Create syslinks 
ln -s -f $PWD/tmux/tmux.conf ~/.tmux.conf
ln -s -f $PWD/tmux/tmux.conf.local ~/.tmux.conf.local

# Install plugins
echo " Install Plugins - run: "
echo "~/.tmux/plugins/tpm/bin/install_plugins"