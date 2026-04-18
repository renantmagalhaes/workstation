{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/users.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/devops.nix
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/themes.nix
    ./modules/services.nix
    ./modules/flatpaks.nix
    ./modules/aliases.nix
    ./modules/apps/1password.nix
    ./modules/apps/vivaldi.nix
    ./modules/apps/google-chrome.nix
    ./modules/desktop/hyprland.nix
    ./modules/power.nix
  ] ++ lib.optional (builtins.pathExists /etc/nixos/mounts.nix) /etc/nixos/mounts.nix
    ++ lib.optional (builtins.pathExists /etc/nixos/host.nix) /etc/nixos/host.nix;

  home-manager.users.rtm = import ./home.nix;
  # Rename conflicting files instead of hard-failing activation
  home-manager.backupFileExtension = "bak";

  # Enable Native Steam (properly hooks up 32-bit libs and drivers)
  programs.steam.enable = true;

  # Enable flakes and the nix-command experimental features
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
    auto-optimise-store = true;
  };

  # GC: keep last 15 system / 3 user generations, collect store older than 90 days (weekly)
  systemd.services.nix-store-cleanup = {
    description = "Nix Store Cleanup";
    serviceConfig.Type = "oneshot";
    script = ''
      # Step 1: delete old generations from all profiles (skip if profile doesn't exist yet)
      ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +15

      if [ -e /nix/var/nix/profiles/per-user/rtm/home-manager ]; then
        ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/per-user/rtm/home-manager --delete-generations +3
      fi

      if [ -e /nix/var/nix/profiles/per-user/rtm/profile ]; then
        ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/per-user/rtm/profile --delete-generations +3
      fi

      # Step 2: single GC pass — collects anything now unreferenced older than 90 days
      ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 90d
    '';
  };

  systemd.timers.nix-store-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4096; # MB
  }];

  # stateVersion tracks initial install — do not bump when switching channels
  system.stateVersion = "25.11";
}
