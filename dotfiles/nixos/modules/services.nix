{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  # Enable the Docker daemon.
  virtualisation.docker.enable = true;

  # Add other services here, e.g.:
  # services.clamav.daemon.enable = true;
  # services.clamav.updater.enable = true;
}
