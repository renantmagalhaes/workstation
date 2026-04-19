{ config, pkgs, ... }:

{
  # 1. Create the directory for WireGuard configs securely
  # This ensures /etc/wireguard exists with 0700 permissions (root only)
  # and ensures the wireguard.conf file is locked down to 0600.
  systemd.tmpfiles.rules = [
    "d /etc/wireguard 0700 root root -"
    "z /etc/wireguard/wireguard.conf 0600 root root -"
  ];

  # 2. Generic WireGuard interface using wg-quick
  # We use the name 'vpn' to keep it provider-agnostic.
  networking.wg-quick.interfaces.vpn = {
    # Point to the file you manually place in /etc/wireguard/wireguard.conf
    configFile = "/etc/wireguard/wireguard.conf";
    
    # Note: NixOS will automatically create a systemd service: wg-quick-vpn.service
  };

  # 3. Smart Start Logic
  # We override the service to only start if the config file actually exists.
  # This prevents boot errors or "failed" units if you haven't put the file there yet.
  systemd.services.wg-quick-vpn.unitConfig.ConditionPathExists = "/etc/wireguard/wireguard.conf";
}
