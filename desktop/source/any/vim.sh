# Space VIM
mkdir ~/.vim/
# curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set cryptmethod=blowfish2" >> ~/.vim/vimrc
echo "set viminfo=" >> ~/.vim/vimrc

# Install neovim
brew install neovim

# Neo VIM
mv ~/.config/nvim ~/.config/nvim.BKP
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
nvim +'hi NormalFloat guibg=#1e222a' +PackerSync