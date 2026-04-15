{ config, ... }:

{
  # Declarative Flatpak management
  # This module depends on nix-flatpak being included in the flake inputs
  services.flatpak = {
    enable = true;
    
    # Configure the flathub remote automatically
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # List of Flatpak applications to install
    # These were moved here because their native Nix versions had insecure dependencies (qtwebengine-5)
    packages = [
      "tv.plex.PlexDesktop"
      "com.stremio.Stremio"
      "com.github.hluk.copyq"

      # Migrated from DevSecTools/software.sh
      "io.dbeaver.DBeaverCommunity"
      "com.getpostman.Postman"
      "com.github.artemanufrij.regextester"
      "net.sourceforge.jpdftweak.jPdfTweak"
    ];

    # Automatically update these apps
    update.auto.enable = true;
    update.onActivation = true;

    # Clean up apps not in the list
    uninstallUnmanaged = true;
  };
}
