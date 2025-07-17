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
    gtk_engines
    go
    nodejs_20
    sqlite
    sassc
    evince
    vscode
    docker-compose
    # gir-rs is not a direct package, it's a Rust development tool
  ];
}
