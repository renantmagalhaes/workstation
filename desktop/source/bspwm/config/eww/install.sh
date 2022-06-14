#!/bin/bash

###### NEED TO RUN WITH ROOT USER #####
###### MORE TESTS FOR AUTOMATIC DEPLOY ARE NEEDED ######

# Install dependencies
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sudo dnf install -y curl dnf-plugins-core cmake gcc clang make rust-glib-sys-devel cairo rust-pangocairo-devel gdk-pixbuf2 gdk-pixbuf2-devel gdk-pixbuf2.x86_64 rust-gdk+default-devel rust-gio-sys-devel rust-gtk-sys-devel.noarch rust-pangocairo-devel gdk-pixbuf2.x86_64 rust-gdk+default-devel 
#sudo xbps-install pkg-config libglib-devel cairo-devel pango-devel atk-devel gdk-pixbuf-devel gtk+3-devel

rustup toolchain install nightly

# link config file
sudo ln -s -f $PWD/config ~/.config/eww

# Clone and build
git clone https://github.com/elkowar/eww ~/GIT-REPOS/CORE/eww
cd ~/GIT-REPOS/CORE/eww
cargo build --release
chmod +x ~/GIT-REPOS/CORE/eww/target/release/eww

# link bin
sudo ln -s -f $PWD/target/release/eww /usr/local/bin/eww



