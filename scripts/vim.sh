# Space VIM
mkdir -p ~/.vim/
# curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set cryptmethod=blowfish2" >> ~/.vim/vimrc
echo "set viminfo=" >> ~/.vim/vimrc

# Neo VIM
rm -rf ~/.local/share/nvim
ln -s -f $PWD/nvim/ ~/.config
# git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
