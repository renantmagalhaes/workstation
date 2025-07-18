{ config, pkgs, ... }:

{
  # We will group all OpenSSH settings together for clarity.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      # This allows the 'root' user to log in with a password.
      # Use with extreme caution.
      #PermitRootLogin = "yes";
    };
  };

  # Enable the Docker daemon.
  virtualisation.docker.enable = true;
}