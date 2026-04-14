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
    fastfetch
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
    zip
    dnsutils
    scrot
    wmctrl
    xdotool
    xorg.xprop
    xwininfo
    xbindkeys
    fzf
    zoxide
    nmon
    pciutils

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
    brasero
    playerctl

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
    papirus-icon-theme
    lm_sensors
    clamav
    clamtk
    #teamviewer
    droidcam
    virtualbox
    solaar
    cifs-utils
    kitty
    
    # Groundwork for TWM (not activated yet)
    polybar
    jgmenu
    sxhkd

    # Desktop Environment Utilities
    alacarte
    kdePackages.kdeconnect-kde
    gnome-keyring

  ];
}
