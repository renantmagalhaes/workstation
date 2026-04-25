{ config, pkgs, ... }:

{
  # Allow unfree packages for things like TeamViewer, etc.
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Shell & CLI tools
    procps
    lsd
    fd
    colorls
    zsh
    tmux
    git
    htop
    meld
    dconf
    nload
    sysstat
    fastfetch
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
    bind
    fzf
    zoxide
    nmon
    pciutils
    wireguard-tools
    lxappearance
    ydotool
    pulseaudio

    # Media
    mpv
    vlc
    krita
    blender
    audacity
    frei0r
    ffmpeg
    imagemagick
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
    lm_sensors
    clamav
    clamtk
    #teamviewer
    droidcam
    virtualbox
    solaar
    cifs-utils
    kitty
    
    # Desktop Environment Utilities
    alacarte
    kdePackages.kdeconnect-kde
    gnome-keyring

    # Native Apps (Migrated from Flatpak)
    kdePackages.kdenlive
    obs-studio
    obsidian
    hydrapaper
  ];
}
