#!/bin/bash

# install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/rtm/.zprofile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/rtm/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install neovim
brew install neovim
