{ config, pkgs, ... }:

{
  # Allow unfree packages for things like TeamViewer, etc.
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Cursors & Fonts
    capitaine-cursors
    apple-cursor
    comixcursors
    afterglow-cursors-recolored
    powerline-fonts
    cantarell-fonts

    # Shell & CLI tools
    lsd
    fd
    colorls
    xcolor
    zsh
    tmux
    git
    htop
    meld
    dconf
    nload
    sysstat
    neofetch
    xclip
    bat
    gawk
    coreutils
    ncdu
    whois
    tree
    pwgen
    vim
    wget
    jq
    ripgrep
    bc
    git-extras
    unrar
    dnsutils
    scrot
    wmctrl
    xdotool
    xorg.xprop

    # Media
    mpv
    vlc
    clementine
    krita
    blender
    audacity
    frei0r
    ffmpeg
    imagemagick
    xwinwrap
    cheese
    flameshot
    scrcpy
    jp2a

    # Networking & System Utilities
    nmap
    wireshark
    gparted
    nettools
    iproute2
    remmina
    vpnc-scripts
    vpnc
    networkmanagerapplet
    openvpn
    filezilla
    piper
    openssl
    inetutils
    libratbag
    timeshift
    android-tools
    materia-theme
    lm_sensors
    clamav
    clamtk
    #teamviewer
    droidcam
    virtualbox
    kitty

  ];
}
