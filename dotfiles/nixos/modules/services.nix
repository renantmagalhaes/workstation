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
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
    };
  };

  # Enable Flatpak service.
  services.flatpak.enable = true;

  # Enable Cron.
  services.cron.enable = true;
}