# Use openSUSE Tumbleweed as base image
FROM opensuse/tumbleweed:latest

# Update the system and install pkgs
RUN zypper -n ref && \
  zypper -n dup && \
  zypper -n install neovim sudo curl git gcc nodejs npm go python312-pip python312-pipx python3 xclip ripgrep

# Create a new user 'nvim' with sudo privileges
RUN useradd -m nvim && \
  echo "nvim ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the HOME environment variable for the nvim user
ENV HOME=/home/nvim
WORKDIR $HOME

# Switch to the 'nvim' user
USER nvim

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Create .vim directory, configure Vim, and clean up Neovim config using absolute paths
RUN mkdir -p $HOME/.vim/ && \
  mkdir -p $HOME/.config/nvim && \
  echo "set ignorecase" >> $HOME/.vim/vimrc && \
  echo "set cryptmethod=blowfish2" >> $HOME/.vim/vimrc && \
  echo "set viminfo=" >> $HOME/.vim/vimrc

# Clone the dotfiles repo and copy the nvim config to the correct location
RUN git clone https://github.com/renantmagalhaes/workstation.git $HOME/dotfiles && \
  cp -r $HOME/dotfiles/dotfiles/nvim $HOME/.config/

# Run Neovim in headless mode to install plugins
RUN nvim --headless +PlugInstall +qall || true

# Default command: open Neovim
CMD ["nvim"]

