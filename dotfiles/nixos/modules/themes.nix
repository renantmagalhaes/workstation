{ config, pkgs, inputs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    cascadia-code
    powerline-fonts
    cantarell-fonts
    font-awesome

    (stdenvNoCC.mkDerivation {
      name = "rofi-custom-fonts";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp ${inputs.grapeNutsFont} $out/share/fonts/truetype/GrapeNuts-Regular.ttf
        cp ${inputs.icomoonFont} $out/share/fonts/truetype/Icomoon-Feather.ttf
      '';
    })
  ];

  environment.systemPackages = with pkgs; [
    # Cursors
    capitaine-cursors
    apple-cursor
    comixcursors
    afterglow-cursors-recolored
    bibata-cursors
    kdePackages.breeze

    # GTK Themes
    catppuccin-gtk
    materia-theme
    fluent-gtk-theme
    graphite-gtk-theme
    colloid-gtk-theme
    dracula-theme
    dracula-qt5-theme
    xdg-desktop-portal-gtk

    # KDE Themes
    materia-kde-theme

    # Icon Themes
    papirus-icon-theme
    tela-icon-theme
    tela-circle-icon-theme
    fluent-icon-theme
    colloid-icon-theme
    reversal-icon-theme
    kdePackages.breeze-icons
    dracula-icon-theme
  ];
}
