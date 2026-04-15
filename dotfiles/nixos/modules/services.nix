{ config, pkgs, ... }:

{
  # We will group all OpenSSH settings together for clarity.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      # This allows the 'root' user to log in with a password.
      # Use with extreme caution.
      #PermitRootLogin = "yes";
    };
  };

  # Enable the Docker daemon.
  virtualisation.docker.enable = true;

  # Enable Libvirtd for KVM/QEMU virtualization.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # Enable Cron.
  services.cron.enable = true;

  # Enable envfs to provide fallback paths like /bin/bash for non-Nix scripts
  services.envfs.enable = true;
}