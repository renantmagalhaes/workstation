{ config, lib, pkgs, ... }:

{
  # Enable the unfree 1Password packages using a predicate.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-gui"
    "1password"
  ];

  # Enable 1Password CLI and GUI
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Required for CLI integration and system authentication on Plasma/some other DEs.
    polkitPolicyOwners = [ "rtm" ]; # <-- Sets your user "rtm" as the policy owner.
  };

  # Configure browser integration for Vivaldi (and others).
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
    '';
    mode = "0755";
  };
}
