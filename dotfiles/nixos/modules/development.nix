{ config, pkgs, ... }:

{
  # Allow unfree packages for things like TeamViewer, etc.
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    python3
    gtk_engines
    go
    nodejs_20
    sqlite
    sassc
    evince
    vscode
    antigravity
    docker-compose
    gcc
    gnumake
    ruby
    rustup
    glibc
    sqlite-interactive # replaces sqlite3-devel in nix
    pkg-config
    libx11
    libxcursor
    libxcrypt-legacy # for older compatibility if needed
  ];
}
