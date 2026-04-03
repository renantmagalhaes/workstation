# Based in Gregory's config <https://github.com/gpakosz>
set -e

# verify tmux
type tmux >/dev/null 2>&1 || {
	echo >&2 "Install tmux before run this script "
	exit 1
}

# Create symlinks first (TPM needs ~/.tmux.conf to exist)
echo "Creating symlinks for tmux configuration..."
ln -s -f "$PWD/dotfiles/tmux/tmux.conf" ~/.tmux.conf
ln -s -f "$PWD/dotfiles/tmux/tmux.conf.local" ~/.tmux.conf.local

# install tpm (tmux plugin manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	echo "Installing Tmux Plugin Manager (TPM)..."
	mkdir -p "$HOME/.tmux/plugins"
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
	echo "TPM already installed. Skipping clone."
fi

# Install plugins
echo "Installing tmux plugins... (this may take a few seconds)"
# Run the installation script with the required variables for better compatibility
if tmux start-server && tmux source-file ~/.tmux.conf; then
	bash "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
else
	echo "Failed to start tmux server or source config. Skipping plugin installation."
fi

# catppuccin setup
echo "Configuring Catppuccin theme components..."
rm -rf ~/.tmux/plugins/tmux/custom
mkdir -p ~/.tmux/plugins/tmux/
ln -s -f "$PWD/dotfiles/tmux/plugins/catppuccin/custom" ~/.tmux/plugins/tmux/custom
ln -s -f "$PWD/dotfiles/tmux/plugins/sys-stats" ~/.tmux/plugins/tmux/sys-stats

echo "Tmux configuration completed successfully."

