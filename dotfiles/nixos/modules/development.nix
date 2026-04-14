{ config, pkgs, ... }:

{
  # Allow unfree packages for things like TeamViewer, etc.
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    python3
    pipx
    gtk-engines
    go
    nodejs_20
    sqlite
    sassc
    evince
    vscode
    docker-compose
    gcc
    gnumake
    ruby
    rustup
    glibc
    openssl
    sqlite-interactive # replaces sqlite3-devel in nix
    pkg-config
    xorg.libX11
    xorg.libXcursor
    libxcrypt-legacy # for older compatibility if needed
  ];
}
